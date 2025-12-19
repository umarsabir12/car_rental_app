require 'docx'

class DocxParserService
  # Styles extracted from sample_string.txt
  STYLES = {
    p: "margin-bottom: 1.5rem; line-height: 1.8; color: #333; font-size: 1.125rem;",
    h2: "font-size: 1.875rem; color: #3A6363; margin-top: 2rem; margin-bottom: 1.5rem; font-weight: 700; line-height: 1.2;",
    h3: "font-size: 1.5rem; color: #3A6363; margin-top: 2rem; margin-bottom: 1rem; font-weight: 700;",
    h4: "font-size: 1.25rem; color: #3A6363; margin-top: 1.5rem; margin-bottom: 0.75rem; font-weight: 700;",
    ul: "margin-bottom: 1.5rem;",
    li: "margin-bottom: 0.5rem; line-height: 1.8; color: #333; font-size: 1.125rem; list-style-type: disc; display: list-item; margin-left: 1.5rem;"
  }

  def initialize(file_path)
    @file_path = file_path
  end

  def convert_to_html
    doc = Docx::Document.open(@file_path)
    html_parts = []
    in_list = false
    @resource_index = 1 # Start from resource_1

    # Access the underlying XML document to iterate over all body elements in order
    doc.doc.xpath('//w:body').children.each do |node|
      # Check for Table
      if node.name == 'tbl'
        if in_list
          html_parts << "</ul>"
          in_list = false
        end
        html_parts << generate_placeholder_html
        next
      end

      # Check for Paragraph
      if node.name == 'p'
        # Check for images/drawings inside the paragraph
        if node.xpath('.//w:drawing').any? || node.xpath('.//w:pict').any?
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
        tag = get_tag_from_style(p.style)
        
        # Robust List Detection
        if node.xpath('.//w:pPr/w:numPr').any?
          tag = 'li'
        end

        # Deep Search: Get all Runs
        all_runs = node.xpath('.//w:r')
        
        # Check Paragraph-level Bold (applies to all runs if not overridden)
        para_bold = false
        p_bold_node = node.xpath('.//w:pPr/w:b').first
        if p_bold_node
           val = p_bold_node['w:val']
           para_bold = true unless val == '0' || val == 'false'
        end

        # Implicit Heading Detection
        if tag == 'p' && text.length > 0 && text.length < 200
           total_run_chars = 0
           bold_chars = 0
           max_font_size = 0
           
           all_runs.each do |r_node|
             r_text = r_node.xpath('.//w:t').text
             next if r_text.empty?
             
             total_run_chars += r_text.length
             
             # Check Run Bold
             is_bold_run = para_bold
             bold_node = r_node.xpath('.//w:rPr/w:b').first
             if bold_node
               val = bold_node['w:val']
               is_bold_run = true unless val == '0' || val == 'false'
             end
             
             if is_bold_run
               bold_chars += r_text.length
             end
             
             # Check Font Size
             size_node = r_node.xpath('.//w:rPr/w:sz').first
             if size_node
               size_val = size_node['w:val'].to_i
               max_font_size = size_val if size_val > max_font_size
             end
           end
           
           is_mostly_bold = (total_run_chars > 0) && ((bold_chars.to_f / total_run_chars) > 0.7)
           is_large_text = max_font_size >= 28
           
           if is_mostly_bold || is_large_text
             tag = 'h3'
           end
        end

        # Handle List Logic
        if tag == 'li'
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
        content = parse_run_nodes(all_runs, para_bold)
        
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
    %{<div style="margin: 2rem 0; text-align: center;">
<img src="#{token}" alt="Resource Image #{index}" style="max-width: 100%; height: auto; border-radius: 8px;" />
</div>}
  end

  def get_tag_from_style(style)
    style_name = style.to_s.downcase.strip
    case style_name
    when /heading\s*1/ then "h2"
    when /heading\s*2/ then "h3"
    when /heading\s*3/ then "h4"
    when /title/ then "h2"
    when /list/ then "li" 
    else "p"
    end
  end

  # Updated to take pure XML nodes + paragraph level bold
  def parse_run_nodes(run_nodes, para_bold = false)
    html_content = ""
    run_nodes.each do |r_node|
      text = r_node.xpath('.//w:t').text
      next if text.empty?

      formatted_text = text.gsub("<", "&lt;").gsub(">", "&gt;")

      # Check Bold
      is_bold = para_bold
      bold_node = r_node.xpath('.//w:rPr/w:b').first
      if bold_node
        val = bold_node['w:val']
        is_bold = true unless val == '0' || val == 'false'
      end

      # Check Italic
      is_italic = false
      italic_node = r_node.xpath('.//w:rPr/w:i').first
      if italic_node
        val = italic_node['w:val']
        is_italic = true unless val == '0' || val == 'false'
      end

      if is_italic
        formatted_text = "<em>#{formatted_text}</em>"
      end
      
      if is_bold
        formatted_text = "<strong>#{formatted_text}</strong>"
      end
      
      html_content += formatted_text
    end
    html_content
  end
  
  def parse_runs(runs)
    "" 
  end
end
