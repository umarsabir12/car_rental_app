require 'rails_helper'

RSpec.describe Blog, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:content) }
    it { should validate_presence_of(:category) }
    it { should validate_presence_of(:author_name) }
  end

  describe 'scopes' do
    describe '.published' do
      let!(:published_blog) { create(:blog, :published) }
      let!(:draft_blog) { create(:blog, :draft) }
      let!(:scheduled_blog) { create(:blog, :scheduled) }

      it 'returns only published blogs' do
        expect(Blog.published).to include(published_blog)
        expect(Blog.published).not_to include(draft_blog, scheduled_blog)
      end
    end
  end

  describe '#to_param' do
    it 'returns slug instead of id' do
      blog = create(:blog, title: 'My Test Blog')
      expect(blog.to_param).to eq('my-test-blog')
    end
  end

  describe 'slug generation' do
    it 'generates slug from title on save' do
      blog = create(:blog, title: 'Hello World')
      expect(blog.slug).to eq('hello-world')
    end

    it 'updates slug when title changes' do
      blog = create(:blog, title: 'Original Title')
      blog.update(title: 'New Title')
      expect(blog.slug).to eq('new-title')
    end
  end
end
