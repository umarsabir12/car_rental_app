require 'rails_helper'

RSpec.describe Blog, type: :model do
  describe 'validations' do
    subject { build(:blog) }

    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:content) }
    it { should validate_presence_of(:category) }
    it { should validate_presence_of(:author_name) }
    it { should validate_presence_of(:slug) }
    it { should validate_uniqueness_of(:slug) }
  end

  describe 'slug format validation' do
    context 'with valid slugs' do
      it 'accepts lowercase letters and hyphens' do
        blog = build(:blog, slug: 'best-car-rental-dubai')
        expect(blog).to be_valid
      end

      it 'accepts lowercase letters with numbers' do
        blog = build(:blog, slug: 'best-car-rental-2025')
        expect(blog).to be_valid
      end

      it 'accepts single word slug' do
        blog = build(:blog, slug: 'guide')
        expect(blog).to be_valid
      end

      it 'accepts slug with multiple hyphens' do
        blog = build(:blog, slug: 'top-10-luxury-cars-dubai')
        expect(blog).to be_valid
      end

      it 'accepts slug with only numbers' do
        blog = build(:blog, slug: '2025')
        expect(blog).to be_valid
      end
    end

    context 'with invalid slugs' do
      it 'rejects slug with uppercase letters' do
        blog = build(:blog, slug: 'Best-Car-Rental')
        expect(blog).to be_invalid
        expect(blog.errors[:slug]).to include("must be lowercase letters, numbers, and hyphens only (e.g., 'my-blog-post')")
      end

      it 'rejects slug with spaces' do
        blog = build(:blog, slug: 'best car rental')
        expect(blog).to be_invalid
        expect(blog.errors[:slug]).to include("must be lowercase letters, numbers, and hyphens only (e.g., 'my-blog-post')")
      end

      it 'rejects slug with underscores' do
        blog = build(:blog, slug: 'best_car_rental')
        expect(blog).to be_invalid
        expect(blog.errors[:slug]).to include("must be lowercase letters, numbers, and hyphens only (e.g., 'my-blog-post')")
      end

      it 'rejects slug starting with hyphen' do
        blog = build(:blog, slug: '-best-car-rental')
        expect(blog).to be_invalid
        expect(blog.errors[:slug]).to include("cannot start with a hyphen")
      end

      it 'rejects slug ending with hyphen' do
        blog = build(:blog, slug: 'best-car-rental-')
        expect(blog).to be_invalid
        expect(blog.errors[:slug]).to include("cannot end with a hyphen")
      end

      it 'rejects slug with consecutive hyphens' do
        blog = build(:blog, slug: 'best--car-rental')
        expect(blog).to be_invalid
        expect(blog.errors[:slug]).to include("cannot contain consecutive hyphens")
      end

      it 'rejects slug with special characters' do
        blog = build(:blog, slug: 'best-car-rental!')
        expect(blog).to be_invalid
        expect(blog.errors[:slug]).to include("must be lowercase letters, numbers, and hyphens only (e.g., 'my-blog-post')")
      end

      it 'rejects slug with non-ASCII characters' do
        blog = build(:blog, slug: 'café-rental')
        expect(blog).to be_invalid
        expect(blog.errors[:slug]).to include("must be lowercase letters, numbers, and hyphens only (e.g., 'my-blog-post')")
      end

      it 'rejects slug with dots' do
        blog = build(:blog, slug: 'best.car.rental')
        expect(blog).to be_invalid
        expect(blog.errors[:slug]).to include("must be lowercase letters, numbers, and hyphens only (e.g., 'my-blog-post')")
      end

      it 'rejects empty slug' do
        blog = build(:blog, slug: '')
        expect(blog).to be_invalid
        expect(blog.errors[:slug]).to include("can't be blank")
      end

      it 'rejects nil slug' do
        blog = build(:blog, slug: nil)
        expect(blog).to be_invalid
        expect(blog.errors[:slug]).to include("can't be blank")
      end
    end

    context 'with edge cases' do
      it 'rejects slug that is only hyphens' do
        blog = build(:blog, slug: '---')
        expect(blog).to be_invalid
      end

      it 'accepts very long valid slug' do
        blog = build(:blog, slug: 'this-is-a-very-long-slug-with-many-words-and-hyphens-2025')
        expect(blog).to be_valid
      end

      it 'rejects slug with trailing whitespace' do
        blog = build(:blog, slug: 'best-car-rental ')
        expect(blog).to be_invalid
      end

      it 'rejects slug with leading whitespace' do
        blog = build(:blog, slug: ' best-car-rental')
        expect(blog).to be_invalid
      end
    end
  end

  describe 'slug uniqueness' do
    let!(:existing_blog) { create(:blog, slug: 'test-blog') }

    it 'prevents duplicate slugs' do
      duplicate_blog = build(:blog, slug: 'test-blog')
      expect(duplicate_blog).to be_invalid
      expect(duplicate_blog.errors[:slug]).to include('has already been taken')
    end

    it 'allows same slug after deletion' do
      existing_blog.destroy
      new_blog = build(:blog, slug: 'test-blog')
      expect(new_blog).to be_valid
    end
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
      blog = create(:blog, slug: 'my-test-blog')
      expect(blog.to_param).to eq('my-test-blog')
    end
  end

  describe 'slug behavior' do
    it 'does not auto-generate slug from title' do
      blog = Blog.new(
        title: 'Hello World',
        content: 'Test content',
        category: 'Tips',
        author_name: 'Test Author'
      )
      expect(blog.slug).to be_nil
    end

    it 'preserves user-provided slug' do
      blog = create(:blog, title: 'My Title', slug: 'custom-slug')
      expect(blog.slug).to eq('custom-slug')
    end

    it 'does not change slug when title changes' do
      blog = create(:blog, title: 'Original Title', slug: 'my-custom-slug')
      blog.update(title: 'New Title')
      expect(blog.slug).to eq('my-custom-slug')
    end

    it 'allows updating slug manually' do
      blog = create(:blog, slug: 'old-slug')
      blog.update(slug: 'new-slug')
      expect(blog.slug).to eq('new-slug')
    end
  end

  describe 'real-world examples' do
    it 'accepts typical blog slugs' do
      valid_slugs = [
        'best-car-rental-dubai-2025',
        'luxury-cars-for-rent',
        'top-10-suv-rentals',
        'guide-2025',
        'car-rental-tips',
        'how-to-rent-a-car-in-dubai',
        'monthly-car-rental-deals',
        'cheap-car-rental-options'
      ]

      valid_slugs.each do |slug|
        blog = build(:blog, slug: slug)
        expect(blog).to be_valid, "Expected '#{slug}' to be valid but got errors: #{blog.errors.full_messages}"
      end
    end

    it 'rejects common invalid patterns' do
      invalid_slugs = {
        'Best-Car-Rental' => 'uppercase',
        'my blog post' => 'spaces',
        'car_rental_guide' => 'underscores',
        '-my-blog' => 'leading hyphen',
        'my-blog-' => 'trailing hyphen',
        'my--blog' => 'consecutive hyphens',
        'car rental!' => 'special characters',
        'café-rental' => 'non-ASCII'
      }

      invalid_slugs.each do |slug, reason|
        blog = build(:blog, slug: slug)
        expect(blog).to be_invalid, "Expected '#{slug}' to be invalid (#{reason})"
      end
    end
  end
end
