require 'rails_helper'

RSpec.describe Listing, type: :model do
  subject { build(:listing) }

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:price_per_night) }
    it { should validate_presence_of(:bedrooms) }
    it { should validate_presence_of(:bathrooms) }
    it { should validate_presence_of(:max_guests) }
    it { should validate_presence_of(:property_type) }
    it { should validate_presence_of(:address) }

    it { should validate_length_of(:title).is_at_least(5).is_at_most(100) }
    it { should validate_length_of(:description).is_at_least(20).is_at_most(2000) }

    it { should validate_numericality_of(:price_per_night).is_greater_than(0) }
    it { should validate_numericality_of(:bedrooms).is_greater_than(0) }
    it { should validate_numericality_of(:bathrooms).is_greater_than(0) }
    it { should validate_numericality_of(:max_guests).is_greater_than(0) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:bookings).dependent(:destroy) }
    it { should have_many(:reviews).dependent(:destroy) }
  end

  describe 'scopes' do
    let!(:cheap_listing) { create(:listing, price_per_night: 50) }
    let!(:expensive_listing) { create(:listing, price_per_night: 200) }
    let!(:apartment) { create(:listing, property_type: :apartment) }
    let!(:house) { create(:listing, property_type: :house) }

    describe '.price_range' do
      it 'returns listings within the price range' do
        expect(Listing.price_range(40, 100)).to include(cheap_listing)
        expect(Listing.price_range(40, 100)).not_to include(expensive_listing)
      end
    end

    describe '.by_property_type' do
      it 'returns listings of the specified property type' do
        expect(Listing.by_property_type(:apartment)).to include(apartment)
        expect(Listing.by_property_type(:apartment)).not_to include(house)
      end
    end
  end

  describe '#average_rating' do
    let(:listing) { create(:listing) }

    context 'when there are no reviews' do
      it 'returns 0' do
        expect(listing.average_rating).to eq(0)
      end
    end

    context 'when there are reviews' do
      before do
        create(:review, listing: listing, rating: 4)
        create(:review, listing: listing, rating: 5)
      end

      it 'returns the average rating' do
        expect(listing.average_rating).to eq(4.5)
      end
    end
  end
end
