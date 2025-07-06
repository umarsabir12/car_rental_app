class Car < ApplicationRecord
    has_many_attached :images
    has_many :bookings
end