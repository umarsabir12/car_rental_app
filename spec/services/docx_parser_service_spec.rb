require 'rails_helper'

RSpec.describe DocxParserService do
  describe '#get_tag_from_style' do
    let(:service) { described_class.new('dummy_path') }

    it 'maps Heading 1 to h1' do
      expect(service.send(:get_tag_from_style, 'Heading 1')).to eq('h1')
    end

    it 'maps Title to h1' do
      expect(service.send(:get_tag_from_style, 'Title')).to eq('h1')
    end

    it 'maps Heading 2 to h2' do
      expect(service.send(:get_tag_from_style, 'Heading 2')).to eq('h2')
    end

    it 'maps Subtitle to h2' do
      expect(service.send(:get_tag_from_style, 'Subtitle')).to eq('h2')
    end

    it 'maps Heading 3 to h3' do
      expect(service.send(:get_tag_from_style, 'Heading 3')).to eq('h3')
    end

    it 'maps Heading 4 to h4' do
      expect(service.send(:get_tag_from_style, 'Heading 4')).to eq('h4')
    end

    it 'maps List Paragraph to li' do
      expect(service.send(:get_tag_from_style, 'List Paragraph')).to eq('li')
    end

    it 'maps unknown styles to p' do
      expect(service.send(:get_tag_from_style, 'Normal')).to eq('p')
    end
  end

  describe 'STYLES constant' do
    it 'defines h1 style' do
      expect(described_class::STYLES[:h1]).to be_present
      expect(described_class::STYLES[:h1]).to include('font-size: 2.25rem')
      expect(described_class::STYLES[:h1]).to include('font-weight: 800')
    end

    it 'defines h2 style' do
      expect(described_class::STYLES[:h2]).to include('font-size: 1.875rem')
    end

    it 'defines h3 style' do
      expect(described_class::STYLES[:h3]).to include('font-size: 1.5rem')
    end
  end
end
