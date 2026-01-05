require "docx"
require "zip"
require "nokogiri"

class DocxParserService
  # Styles extracted from sample_string.txt
  STYLES = {
    p: "margin-bottom: 1.5rem; line-height: 1.8; color: #333; font-size: 1.125rem;",
    h1: "font-size: 2.25rem; color: #3A6363; margin-top: 2.5rem; margin-bottom: 1.5rem; font-weight: 800; line-height: 1.2;",
    h2: "font-size: 1.875rem; color: #3A6363; margin-top: 2rem; margin-bottom: 1.5rem; font-weight: 700; line-height: 1.2;",
    h3: "font-size: 1.5rem; color: #3A6363; margin-top: 2rem; margin-bottom: 1rem; font-weight: 700;",
    h4: "font-size: 1.25rem; color: #3A6363; margin-top: 1.5rem; margin-bottom: 0.75rem; font-weight: 700;",
    ul: "margin-bottom: 1.5rem;",
    li: "margin-bottom: 0.5rem; line-height: 1.8; color: #333; font-size: 1.125rem; list-style-type: disc; display: list-item; margin-left: 1.5rem;"
  }

  def initialize(file_path)
    @file_path = file_path
    @relationships = {}
    parse_relationships
  end

  def convert_to_html
    doc = Docx::Document.open(@file_path)
    html_parts = []
    in_list = false
    @resource_index = 1 # Start from resource_1

    # Access the underlying XML document to iterate over all body elements in order
    doc.doc.xpath("//w:body").children.each do |node|
      # Check for Table
      if node.name == "tbl"
        if in_list
          html_parts << "</ul>"
          in_list = false
        end
        html_parts << generate_placeholder_html
        next
      end

      # Check for Paragraph
      if node.name == "p"
        # Check for images/drawings inside the paragraph
        if node.xpath(".//w:drawing").any? || node.xpath(".//w:pict").any?
          if in_list
            html_parts << "</ul>"
            in_list = false
          end
          html_parts << generate_placeholder_html
        end

        # Wrap in gem's Paragraph object
        p = Docx::Elements::Containers::Paragraph.new(node)
        text = p.text.strip

        # Identify Tag via Style or XML properties
        style_id = p.style
        if style_id.to_s.strip.empty? || style_id.to_s.downcase == "normal"
          s_node = node.xpath(".//w:pPr/w:pStyle").first
          style_id = s_node["w:val"] if s_node
        end
        tag = get_tag_from_style(style_id)

        # Robust List Detection
        if node.xpath(".//w:pPr/w:numPr").any? && tag == "p"
          tag = "li"
        end

        # Deep Search: Get all children (runs and hyperlinks) to preserve order
        child_nodes = node.xpath("w:r | w:hyperlink")

        # Check Paragraph-level Bold and Size
        para_bold = false
        p_bold_node = node.xpath(".//w:pPr/w:b").first
        # Also check for bold in pPr > rPr
        unless p_bold_node
          p_bold_node = node.xpath(".//w:pPr/w:rPr/w:b").first
        end

        if p_bold_node
           val = p_bold_node["w:val"]
           para_bold = true unless val == "0" || val == "false"
        end

        # Check Paragraph-level Font Size (check both standard and complex script sizes)
        para_size = 0
        p_size_node = node.xpath(".//w:pPr/w:rPr/w:sz").first
        p_size_cs_node = node.xpath(".//w:pPr/w:rPr/w:szCs").first

        if p_size_node
          para_size = p_size_node["w:val"].to_i
        elsif p_size_cs_node
          para_size = p_size_cs_node["w:val"].to_i
        end

        # Logging for debug
        Rails.logger.info "DocxParser: Text='#{text[0..30]}...' Style='#{p.style}' TagFromStyle='#{tag}' ParaSize=#{para_size}"

        # Implicit Heading Detection
        if tag == "p" && text.length > 0
           total_run_chars = 0
           bold_chars = 0
           max_font_size = para_size # Start with paragraph default size

           # Analyze children for styling clues
           child_nodes.each do |child|
             if child.name == "r"
               total_run_chars, bold_chars, max_font_size = process_run_for_stats(child, para_bold, total_run_chars, bold_chars, max_font_size)
             elsif child.name == "hyperlink"
               child.xpath(".//w:r").each do |r_node|
                 total_run_chars, bold_chars, max_font_size = process_run_for_stats(
                   r_node, para_bold, total_run_chars, bold_chars, max_font_size
                 )
               end
             end
           end



            # Logic based on standard Word half-points (28 = 14pt, 32 = 16pt, 40 = 20pt)
            if max_font_size >= 40
              tag = "h1"
            elsif max_font_size >= 32
              tag = "h2"
            elsif max_font_size >= 28
              tag = "h3"
            end
        end

        # Handle List Logic
        if tag == "li"
          unless in_list
            html_parts << "<ul style=\"#{STYLES[:ul]}\">"
            in_list = true
          end
        else
          if in_list
            html_parts << "</ul>"
            in_list = false
          end
        end

        next if text.empty?

        # Parse content
        content = parse_mixed_nodes(child_nodes, doc, para_bold)

        style = STYLES[tag.to_sym]
        if style
          html_parts << "<#{tag} style=\"#{style}\">#{content}</#{tag}>"
        else
          html_parts << "<#{tag}>#{content}</#{tag}>"
        end
      end
    end

    if in_list
      html_parts << "</ul>"
    end

    html_parts.join("\n")
  rescue => e
    Rails.logger.error "DocxParsingError: #{e.message}"
    "<p style=\"#{STYLES[:p]}\">Error parsing document content: #{e.message}</p>"
  end

  private

  def generate_placeholder_html
    index = @resource_index
    @resource_index += 1
    token = "{{resource_#{index}}}"
    %(<div style="margin: 2rem 0; display: flex; justify-content: center; width: 100%;">
<img src="#{token}" alt="Resource Image #{index}" style="max-width: 100%; height: auto; border-radius: 8px; display: block;" />
</div>)
  end

  def parse_relationships
    Zip::File.open(@file_path) do |zip_file|
      # Relationships for the main document are usually in word/_rels/document.xml.rels
      entry = zip_file.find_entry("word/_rels/document.xml.rels")
      return unless entry

      xml = Nokogiri::XML(entry.get_input_stream.read)
      xml.xpath("//xmlns:Relationship").each do |rel|
        id = rel["Id"]
        target = rel["Target"]
        @relationships[id] = target if id && target
      end
    end
  rescue => e
    Rails.logger.error "DocxParserService: Error parsing relationships: #{e.message}"
  end

  def get_tag_from_style(style)
    style_name = style.to_s.downcase.strip
    case style_name
    when /heading\s*1/, /^title$/ then "h1"
    when /heading\s*2/, /subtitle/ then "h2"
    when /heading\s*3/ then "h3"
    when /heading\s*4/ then "h4"
    when /list/, /bullet/ then "li"
    else "p"
    end
  end

  # New method to handle both runs and hyperlinks
  def parse_mixed_nodes(nodes, doc, para_bold = false)
    html_content = ""
    nodes.each do |node|
      if node.name == "hyperlink"
        # Extract URL
        rel_id = node["r:id"]
        # doc.relationships is a hash of id => relationship object
        # relationship object has .target for the URL
        url = "#"
        if rel_id && @relationships[rel_id]
          url = @relationships[rel_id]
        end

        # Parse inner runs of the hyperlink
        inner_content = parse_mixed_nodes(node.xpath("w:r"), doc, para_bold)
        html_content += "<a href=\"#{url}\" target=\"_blank\" style=\"color: #3A6363; text-decoration: underline;\">#{inner_content}</a>"
      else
        # It's a standard run
        html_content += process_single_run(node, para_bold)
      end
    end
    html_content
  end

  def process_single_run(r_node, para_bold)
    text = r_node.xpath(".//w:t").text
    return "" if text.empty?

    formatted_text = text.gsub("<", "&lt;").gsub(">", "&gt;")

    # Check Bold
    is_bold = para_bold
    bold_node = r_node.xpath(".//w:rPr/w:b").first
    if bold_node
      val = bold_node["w:val"]
      is_bold = true unless val == "0" || val == "false"
    end

    # Check Italic
    is_italic = false
    italic_node = r_node.xpath(".//w:rPr/w:i").first
    if italic_node
      val = italic_node["w:val"]
      is_italic = true unless val == "0" || val == "false"
    end

    if is_italic
      formatted_text = "<em>#{formatted_text}</em>"
    end

    if is_bold
      formatted_text = "<strong>#{formatted_text}</strong>"
    end

    formatted_text
  end

  # Helper to accumulate stats for heading detection
  def process_run_for_stats(r_node, para_bold, total_run_chars, bold_chars, max_font_size)
     r_text = r_node.xpath(".//w:t").text
     unless r_text.empty?
       total_run_chars += r_text.length

       # Check Run Bold
       is_bold_run = para_bold
       bold_node = r_node.xpath(".//w:rPr/w:b").first
       if bold_node
         val = bold_node["w:val"]
         is_bold_run = true unless val == "0" || val == "false"
       end

       if is_bold_run
         bold_chars += r_text.length
       end

       # Check Font Size (standard and complex script)
       size_node = r_node.xpath(".//w:rPr/w:sz").first
       size_cs_node = r_node.xpath(".//w:rPr/w:szCs").first

       val_to_use = 0
       if size_node
         val_to_use = size_node["w:val"].to_i
       elsif size_cs_node
         val_to_use = size_cs_node["w:val"].to_i
       end

       max_font_size = val_to_use if val_to_use > max_font_size
     end
     [ total_run_chars, bold_chars, max_font_size ]
  end

  def parse_runs(runs)
    ""
  end
end
