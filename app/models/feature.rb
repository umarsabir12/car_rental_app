class Feature < ApplicationRecord
  has_many :car_features, dependent: :destroy
  has_many :cars, through: :car_features

  validates :name, presence: true, uniqueness: true

  scope :common, -> { where(common: true) }
  scope :premium, -> { where(common: false) }

  after_create :handle_common_feature_creation, if: :common?
  after_update :handle_common_status_change, if: :saved_change_to_common?

  private

  def handle_common_feature_creation
    self.car_ids = Car.all.ids
  end

  def handle_common_status_change
    if common?
      handle_changed_to_common
    end
  end

  def handle_changed_to_common
    self.car_ids = (self.car_ids + Car.pluck(:id)).uniq
  end
end
