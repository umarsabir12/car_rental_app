#!/usr/bin/env ruby

require 'json'
require 'ruby-docx'

# JSON data
json_data = {
  "forced_choice" => [
    # ... existing code ...
  ],
  "scenario_choice" => [
    # ... existing code ...
  ],
  "likert" => [
    # ... existing code ...
  ]
}

# Create a new Word document
doc = RubyDocx::Document.new

# Add title
doc.add_heading("Assessment Questionnaire", 0)

# Process Forced Choice Questions
doc.add_heading("Forced Choice Questions", 1)
json_data["forced_choice"].each_with_index do |question, index|
  doc.add_heading("Question #{index + 1} (#{question['block_id']})", 2)
  doc.add_paragraph(question['prompt'])
  
  question['options'].each do |key, option|
    doc.add_paragraph("#{key}. #{option['text']} (#{option['subtype']})")
  end
  doc.add_paragraph("") # Add spacing
end

# Process Scenario Choice Questions
doc.add_heading("Scenario Choice Questions", 1)
json_data["scenario_choice"].each_with_index do |question, index|
  doc.add_heading("Scenario #{index + 1} (#{question['block_id']})", 2)
  doc.add_paragraph(question['prompt'])
  
  question['options'].each do |key, option|
    doc.add_paragraph("#{key}. #{option['text']} (#{option['subtype']})")
  end
  doc.add_paragraph("") # Add spacing
end

# Process Likert Scale Questions
doc.add_heading("Likert Scale Questions", 1)
doc.add_paragraph("Rate each statement on a scale from 1 (Strongly Disagree) to 5 (Strongly Agree):")
doc.add_paragraph("")

json_data["likert"].each_with_index do |item, index|
  doc.add_paragraph("#{index + 1}. #{item['text']} (#{item['subtype']})")
end

# Save the document
doc.save("psychological_assessment_questionnaire.docx")
puts "Document saved as 'psychological_assessment_questionnaire.docx'"



