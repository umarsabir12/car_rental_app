class Discount < ApplicationRecord
  belongs_to :vendor, optional: true

  # PostgreSQL array column - no serialize needed, handled natively
  # The category column is a text[] type in the database

  validates :discount_percentage, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :active, inclusion: { in: [ true, false ] }
  validate :categories_exist_in_system
  validate :vendor_or_category_required

  scope :active, -> { where(active: true) }
  scope :for_vendor, ->(vendor_id) { where(vendor_id: vendor_id) }
  scope :for_category, ->(category_name) {
    where("? = ANY(category)", category_name).or(where("category = '{}' OR category IS NULL"))
  }

  # Find applicable discount for a specific car
  def self.applicable_for_car(car)
    return nil unless car&.category

    # Priority order:
    # 1. Vendor-specific discount for specific category
    # 2. Category-based discount (all vendors)
    # 3. Vendor-specific discount for all categories
    active
      .where("(vendor_id = ? OR vendor_id IS NULL) AND (? = ANY(category) OR category = '{}' OR category IS NULL)", car.vendor_id, car.category)
      .order(
        Arel.sql(
          sanitize_sql_array([
            "CASE
              WHEN vendor_id = ? AND ? = ANY(category) THEN 1
              WHEN vendor_id IS NULL AND ? = ANY(category) THEN 2
              WHEN vendor_id = ? AND (category = '{}' OR category IS NULL) THEN 3
              ELSE 4
            END,
            discount_percentage DESC",
            car.vendor_id, car.category,
            car.category,
            car.vendor_id
          ])
        )
      )
      .first
  end

  def applies_to_all_categories?
    category.blank? || category.empty?
  end

  def applies_to_all_vendors?
    vendor_id.blank?
  end

  def display_name
    vendor_name = applies_to_all_vendors? ? "All Vendors" : vendor.company_name
    category_name = applies_to_all_categories? ? "All Categories" : category.join(", ")
    "#{vendor_name} - #{category_name} (#{discount_percentage}%)"
  end

  def category_list
    applies_to_all_categories? ? "All Categories" : category.join(", ")
  end

  def vendor_display
    applies_to_all_vendors? ? "All Vendors" : vendor.company_name
  end

  private

  def categories_exist_in_system
    return if category.blank? || category.empty?

    available_categories = Car.distinct.pluck(:category).compact
    invalid_categories = category - available_categories

    if invalid_categories.any?
      errors.add(:category, "includes invalid categories: #{invalid_categories.join(', ')}")
    end
  end

  def vendor_or_category_required
    if vendor_id.blank? && (category.blank? || category.empty?)
      errors.add(:base, "Either vendor or at least one category must be selected")
    end
  end
end
