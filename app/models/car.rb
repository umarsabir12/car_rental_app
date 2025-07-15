class Car < ApplicationRecord
  belongs_to :vendor, optional: true
  has_many_attached :images
  has_many :bookings
end