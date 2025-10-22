require 'rails_helper'

RSpec.describe Booking, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:listing) }
  end

  describe 'validations' do
    it { should validate_presence_of(:start_date) }
    it { should validate_presence_of(:end_date) }
    it { should validate_presence_of(:guests_amount) }
    it { should validate_numericality_of(:guests_amount).is_greater_than(0) }

    describe 'end_date_after_start_date' do
      it 'is invalid when end_date is before start_date' do
        booking = build(:booking, start_date: Date.today + 5, end_date: Date.today + 3)
        expect(booking).not_to be_valid
        expect(booking.errors[:end_date]).to include('must be after the start date')
      end

      it 'is invalid when end_date equals start_date' do
        booking = build(:booking, start_date: Date.today + 5, end_date: Date.today + 5)
        expect(booking).not_to be_valid
        expect(booking.errors[:end_date]).to include('must be after the start date')
      end

      it 'is valid when end_date is after start_date' do
        booking = build(:booking, start_date: Date.today + 5, end_date: Date.today + 10)
        expect(booking).to be_valid
      end
    end

    describe 'start_date_cannot_be_in_the_past' do
      context 'on create' do
        it 'is invalid when start_date is in the past' do
          booking = build(:booking, start_date: Date.yesterday)
          expect(booking).not_to be_valid
          expect(booking.errors[:start_date]).to include('cannot be in the past')
        end

        it 'is valid when start_date is today' do
          booking = build(:booking, start_date: Date.today, end_date: Date.tomorrow)
          expect(booking).to be_valid
        end

        it 'is valid when start_date is in the future' do
          booking = build(:booking, start_date: Date.tomorrow, end_date: Date.tomorrow + 1)
          expect(booking).to be_valid
        end
      end

      context 'on update' do
        it 'allows updating a booking with past dates' do
          # Create a booking with future dates first, then update to past dates manually
          booking = create(:booking, start_date: Date.today + 1, end_date: Date.today + 5)
          # Update the dates directly without triggering validation
          booking.update_columns(start_date: Date.yesterday, end_date: Date.today)
          # Now update another attribute
          booking.guests_amount = 3
          expect(booking).to be_valid
          expect(booking.save).to be true
        end
      end
    end

    describe 'no_overlapping_bookings' do
      let(:listing) { create(:listing) }
      let(:user1) { create(:user) }
      let(:user2) { create(:user) }

      context 'when creating a new booking' do
        it 'is valid when there are no overlapping bookings' do
          create(:booking, listing: listing, start_date: Date.today + 1, end_date: Date.today + 5)
          new_booking = build(:booking, listing: listing, start_date: Date.today + 6, end_date: Date.today + 10)

          expect(new_booking).to be_valid
        end

        it 'is invalid when dates completely overlap an existing booking' do
          create(:booking, listing: listing, start_date: Date.today + 5, end_date: Date.today + 10)
          new_booking = build(:booking, listing: listing, start_date: Date.today + 6, end_date: Date.today + 9)

          expect(new_booking).not_to be_valid
          expect(new_booking.errors[:base]).to include('This listing is already booked for the selected dates')
        end

        it 'is invalid when start_date falls within an existing booking' do
          create(:booking, listing: listing, start_date: Date.today + 5, end_date: Date.today + 10)
          new_booking = build(:booking, listing: listing, start_date: Date.today + 7, end_date: Date.today + 12)

          expect(new_booking).not_to be_valid
          expect(new_booking.errors[:base]).to include('This listing is already booked for the selected dates')
        end

        it 'is invalid when end_date falls within an existing booking' do
          create(:booking, listing: listing, start_date: Date.today + 5, end_date: Date.today + 10)
          new_booking = build(:booking, listing: listing, start_date: Date.today + 3, end_date: Date.today + 7)

          expect(new_booking).not_to be_valid
          expect(new_booking.errors[:base]).to include('This listing is already booked for the selected dates')
        end

        it 'is invalid when new booking encompasses an existing booking' do
          create(:booking, listing: listing, start_date: Date.today + 5, end_date: Date.today + 10)
          new_booking = build(:booking, listing: listing, start_date: Date.today + 3, end_date: Date.today + 12)

          expect(new_booking).not_to be_valid
          expect(new_booking.errors[:base]).to include('This listing is already booked for the selected dates')
        end

        it 'is valid when overlapping with a cancelled booking' do
          create(:booking, :cancelled, listing: listing, start_date: Date.today + 5, end_date: Date.today + 10)
          new_booking = build(:booking, listing: listing, start_date: Date.today + 6, end_date: Date.today + 9)

          expect(new_booking).to be_valid
        end

        it 'is valid when overlapping with a rejected booking' do
          create(:booking, :rejected, listing: listing, start_date: Date.today + 5, end_date: Date.today + 10)
          new_booking = build(:booking, listing: listing, start_date: Date.today + 6, end_date: Date.today + 9)

          expect(new_booking).to be_valid
        end

        it 'is valid for the same dates on a different listing' do
          other_listing = create(:listing)
          create(:booking, listing: listing, start_date: Date.today + 5, end_date: Date.today + 10)
          new_booking = build(:booking, listing: other_listing, start_date: Date.today + 5, end_date: Date.today + 10)

          expect(new_booking).to be_valid
        end
      end

      context 'when updating an existing booking' do
        it 'is valid when updating own booking without changing dates' do
          booking = create(:booking, listing: listing, start_date: Date.today + 5, end_date: Date.today + 10)
          booking.guests_amount = 4

          expect(booking).to be_valid
        end

        it 'is valid when changing dates to non-overlapping range' do
          create(:booking, listing: listing, start_date: Date.today + 5, end_date: Date.today + 10)
          booking = create(:booking, listing: listing, start_date: Date.today + 15, end_date: Date.today + 20)
          booking.start_date = Date.today + 11
          booking.end_date = Date.today + 14

          expect(booking).to be_valid
        end

        it 'is invalid when changing dates to overlap another booking' do
          create(:booking, listing: listing, start_date: Date.today + 5, end_date: Date.today + 10)
          booking = create(:booking, listing: listing, start_date: Date.today + 15, end_date: Date.today + 20)
          booking.start_date = Date.today + 6
          booking.end_date = Date.today + 9

          expect(booking).not_to be_valid
          expect(booking.errors[:base]).to include('This listing is already booked for the selected dates')
        end
      end
    end
  end

  describe 'enums' do
    it 'defines status enum with correct values' do
      expect(Booking.statuses).to eq({
        'pending' => 0,
        'confirmed' => 1,
        'cancelled' => 2,
        'completed' => 3,
        'rejected' => 4
      })
    end

    it 'has pending as default status' do
      booking = create(:booking)
      expect(booking.reload.status).to eq('pending')
    end

    describe 'status transitions' do
      let(:booking) { create(:booking) }

      it 'can transition from pending to confirmed' do
        expect(booking.pending?).to be true
        booking.confirmed!
        expect(booking.confirmed?).to be true
      end

      it 'can transition from pending to cancelled' do
        expect(booking.pending?).to be true
        booking.cancelled!
        expect(booking.cancelled?).to be true
      end

      it 'can transition from pending to rejected' do
        expect(booking.pending?).to be true
        booking.rejected!
        expect(booking.rejected?).to be true
      end

      it 'can transition from confirmed to cancelled' do
        booking.confirmed!
        booking.cancelled!
        expect(booking.cancelled?).to be true
      end

      it 'can transition from confirmed to completed' do
        booking.confirmed!
        booking.completed!
        expect(booking.completed?).to be true
      end
    end
  end

  describe 'scopes' do
    let(:listing) { create(:listing) }

    before do
      # Create bookings with different date ranges to avoid overlaps
      create(:booking, :pending, listing: listing, start_date: Date.today + 1, end_date: Date.today + 5)
      create(:booking, :confirmed, listing: listing, start_date: Date.today + 6, end_date: Date.today + 10)
      create(:booking, :cancelled, listing: listing, start_date: Date.today + 11, end_date: Date.today + 15)
      create(:booking, :completed, listing: listing, start_date: Date.today + 16, end_date: Date.today + 20)
      create(:booking, :rejected, listing: listing, start_date: Date.today + 21, end_date: Date.today + 25)
    end

    it 'filters bookings by pending status' do
      expect(Booking.pending.count).to eq(1)
    end

    it 'filters bookings by confirmed status' do
      expect(Booking.confirmed.count).to eq(1)
    end

    it 'filters bookings by cancelled status' do
      expect(Booking.cancelled.count).to eq(1)
    end

    it 'filters bookings by completed status' do
      expect(Booking.completed.count).to eq(1)
    end

    it 'filters bookings by rejected status' do
      expect(Booking.rejected.count).to eq(1)
    end
  end

  describe 'factory' do
    it 'creates a valid booking' do
      booking = build(:booking)
      expect(booking).to be_valid
    end

    it 'creates a valid confirmed booking' do
      booking = build(:booking, :confirmed)
      expect(booking.confirmed?).to be true
    end

    it 'creates a valid cancelled booking' do
      booking = build(:booking, :cancelled)
      expect(booking.cancelled?).to be true
    end

    it 'creates a valid completed booking' do
      booking = build(:booking, :completed)
      expect(booking.completed?).to be true
    end

    it 'creates a valid rejected booking' do
      booking = build(:booking, :rejected)
      expect(booking.rejected?).to be true
    end
  end
end
