class Listing < ApplicationRecord
  belongs_to :user
  # has_many :bookings, dependent: :destroy
  # has_many :reviews, dependent: :destroy
  has_many_attached :photos

  enum :property_type, {
    house: 0,
    apartment: 1,
    guesthouse: 2,
    hotel: 3,
    villa: 4,
    cabin: 5
  }

  validates :title, presence: true, length: { minimum: 5, maximum: 100 }
  validates :description, presence: true, length: { minimum: 20, maximum: 2000 }
  validates :price_per_night, presence: true, numericality: { greater_than: 0 }
  validates :bedrooms, :bathrooms, :max_guests, presence: true, numericality: { greater_than: 0 }
  validates :property_type, presence: true
  validates :address, presence: true

  scope :price_range, ->(min_price, max_price) {
    where(price_per_night: min_price..max_price) if min_price && max_price
  }

  scope :by_property_type, ->(type) {
    where(property_type: type) if type.present?
  }

  scope :by_rooms, ->(bedrooms) {
    where("bedrooms >= ?", bedrooms) if bedrooms.present?
  }

  def average_rating
    # reviews.average(:rating).to_f.round(2)
  end
end
