require 'rails_helper'

RSpec.describe Discount, type: :model do
  describe 'associations' do
    it { should belong_to(:vendor).optional }
  end

  describe 'validations' do
    it { should validate_presence_of(:discount_percentage) }
    it { should validate_numericality_of(:discount_percentage).is_greater_than(0).is_less_than_or_equal_to(100) }
    it { should validate_inclusion_of(:active).in_array([ true, false ]) }

    describe 'vendor_or_category_required' do
      it 'is invalid without vendor and category' do
        discount = build(:discount, vendor_id: nil, category: [])
        expect(discount).not_to be_valid
        expect(discount.errors[:base]).to include('Either vendor or at least one category must be selected')
      end

      it 'is valid with only vendor' do
        vendor = create(:vendor)
        discount = build(:discount, vendor: vendor, category: [])
        expect(discount).to be_valid
      end

      it 'is valid with only category' do
        create(:car, category: 'Luxury')
        discount = build(:discount, vendor_id: nil, category: [ 'Luxury' ])
        expect(discount).to be_valid
      end

      it 'is valid with both vendor and category' do
        vendor = create(:vendor)
        create(:car, vendor: vendor, category: 'Luxury')
        discount = build(:discount, vendor: vendor, category: [ 'Luxury' ])
        expect(discount).to be_valid
      end
    end

    describe 'categories_exist_in_system' do
      it 'is invalid with non-existent categories' do
        create(:car, category: 'Economy')
        discount = build(:discount, vendor_id: nil, category: [ 'NonExistentCategory' ])
        expect(discount).not_to be_valid
        expect(discount.errors[:category]).to include('includes invalid categories: NonExistentCategory')
      end

      it 'is valid with existing categories' do
        create(:car, category: 'Luxury')
        discount = build(:discount, vendor_id: nil, category: [ 'Luxury' ])
        expect(discount).to be_valid
      end
    end
  end

  describe 'scopes' do
    describe '.active' do
      let!(:active_discount) { create(:discount, active: true) }
      let!(:inactive_discount) { create(:discount, active: false) }

      it 'returns only active discounts' do
        expect(Discount.active).to include(active_discount)
        expect(Discount.active).not_to include(inactive_discount)
      end
    end

    describe '.for_vendor' do
      let(:vendor1) { create(:vendor) }
      let(:vendor2) { create(:vendor) }
      let!(:vendor1_discount) { create(:discount, vendor: vendor1) }
      let!(:vendor2_discount) { create(:discount, vendor: vendor2) }

      it 'returns discounts for specific vendor' do
        expect(Discount.for_vendor(vendor1.id)).to include(vendor1_discount)
        expect(Discount.for_vendor(vendor1.id)).not_to include(vendor2_discount)
      end
    end

    describe '.for_category' do
      before do
        create(:car, category: 'Luxury')
        create(:car, category: 'Economy')
      end

      let!(:luxury_discount) { create(:discount, category: [ 'Luxury' ]) }
      let!(:economy_discount) { create(:discount, category: [ 'Economy' ]) }

      it 'returns discounts for specific category' do
        expect(Discount.for_category('Luxury')).to include(luxury_discount)
        expect(Discount.for_category('Luxury')).not_to include(economy_discount)
      end
    end
  end

  describe '.applicable_for_car' do
    let(:vendor) { create(:vendor) }
    let!(:car) { create(:car, vendor: vendor, category: 'Luxury') }

    context 'with vendor-specific and category-specific discount' do
      let!(:discount) { create(:discount, vendor: vendor, category: [ 'Luxury' ], discount_percentage: 20, active: true) }

      it 'returns the discount' do
        expect(Discount.applicable_for_car(car)).to eq(discount)
      end
    end

    context 'with category-only discount (all vendors)' do
      let!(:discount) { create(:discount, vendor_id: nil, category: [ 'Luxury' ], discount_percentage: 15, active: true) }

      it 'returns the discount' do
        expect(Discount.applicable_for_car(car)).to eq(discount)
      end
    end

    context 'with vendor-specific, all categories discount' do
      let!(:discount) { create(:discount, vendor: vendor, category: [], discount_percentage: 10, active: true) }

      it 'returns the discount' do
        expect(Discount.applicable_for_car(car)).to eq(discount)
      end
    end

    context 'with multiple applicable discounts (priority order)' do
      let!(:vendor_category_discount) { create(:discount, vendor: vendor, category: [ 'Luxury' ], discount_percentage: 25, active: true) }
      let!(:category_only_discount) { create(:discount, vendor_id: nil, category: [ 'Luxury' ], discount_percentage: 15, active: true) }
      let!(:vendor_all_categories_discount) { create(:discount, vendor: vendor, category: [], discount_percentage: 10, active: true) }

      it 'returns the highest priority discount (vendor + category)' do
        expect(Discount.applicable_for_car(car)).to eq(vendor_category_discount)
      end
    end

    context 'with inactive discount' do
      let!(:discount) { create(:discount, vendor: vendor, category: [ 'Luxury' ], discount_percentage: 20, active: false) }

      it 'returns nil' do
        expect(Discount.applicable_for_car(car)).to be_nil
      end
    end

    context 'with no applicable discount' do
      it 'returns nil' do
        expect(Discount.applicable_for_car(car)).to be_nil
      end
    end

    context 'when car has no category' do
      let(:car_without_category) { create(:car, vendor: vendor, category: nil) }

      it 'returns nil' do
        expect(Discount.applicable_for_car(car_without_category)).to be_nil
      end
    end
  end

  describe '#applies_to_all_categories?' do
    it 'returns true when category is empty array' do
      discount = build(:discount, category: [])
      expect(discount.applies_to_all_categories?).to be true
    end

    it 'returns true when category is nil' do
      discount = build(:discount, category: nil)
      expect(discount.applies_to_all_categories?).to be true
    end

    it 'returns false when category has values' do
      create(:car, category: 'Luxury')
      discount = build(:discount, category: [ 'Luxury' ])
      expect(discount.applies_to_all_categories?).to be false
    end
  end

  describe '#applies_to_all_vendors?' do
    it 'returns true when vendor_id is nil' do
      create(:car, category: 'Luxury')
      discount = build(:discount, vendor_id: nil, category: [ 'Luxury' ])
      expect(discount.applies_to_all_vendors?).to be true
    end

    it 'returns false when vendor_id is present' do
      vendor = create(:vendor)
      discount = build(:discount, vendor: vendor)
      expect(discount.applies_to_all_vendors?).to be false
    end
  end

  describe '#display_name' do
    it 'shows vendor name and category name with percentage' do
      vendor = create(:vendor, company_name: 'Test Vendor')
      create(:car, vendor: vendor, category: 'Luxury')
      discount = build(:discount, vendor: vendor, category: [ 'Luxury' ], discount_percentage: 20)
      expect(discount.display_name).to eq('Test Vendor - Luxury (20.0%)')
    end

    it 'shows "All Vendors" when vendor is nil' do
      create(:car, category: 'Economy')
      discount = build(:discount, vendor_id: nil, category: [ 'Economy' ], discount_percentage: 15)
      expect(discount.display_name).to eq('All Vendors - Economy (15.0%)')
    end

    it 'shows "All Categories" when category is empty' do
      vendor = create(:vendor, company_name: 'Test Vendor')
      discount = build(:discount, vendor: vendor, category: [], discount_percentage: 10)
      expect(discount.display_name).to eq('Test Vendor - All Categories (10.0%)')
    end
  end

  describe '#category_list' do
    it 'returns "All Categories" when category is empty' do
      discount = build(:discount, category: [])
      expect(discount.category_list).to eq('All Categories')
    end

    it 'returns joined category names' do
      create(:car, category: 'Luxury')
      create(:car, category: 'Economy')
      discount = build(:discount, category: [ 'Luxury', 'Economy' ])
      expect(discount.category_list).to eq('Luxury, Economy')
    end
  end

  describe '#vendor_display' do
    it 'returns "All Vendors" when vendor_id is nil' do
      create(:car, category: 'Luxury')
      discount = build(:discount, vendor_id: nil, category: [ 'Luxury' ])
      expect(discount.vendor_display).to eq('All Vendors')
    end

    it 'returns vendor company name when vendor is present' do
      vendor = create(:vendor, company_name: 'Test Vendor')
      discount = build(:discount, vendor: vendor)
      expect(discount.vendor_display).to eq('Test Vendor')
    end
  end
end
