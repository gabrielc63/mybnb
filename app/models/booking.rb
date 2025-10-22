class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :listing

  enum :status, {
    pending: 0,      # Booking request submitted, awaiting host approval
    confirmed: 1,    # Host has confirmed the booking
    cancelled: 2,    # Booking was cancelled (by guest or host)
    completed: 3,    # Stay has been completed
    rejected: 4      # Host rejected the booking request
  }, default: :pending

  validates :start_date, :end_date, :guests_amount, presence: true
  validates :guests_amount, numericality: { greater_than: 0 }
  validate :end_date_after_start_date
  validate :start_date_cannot_be_in_the_past, on: :create
  validate :no_overlapping_bookings

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if end_date <= start_date
      errors.add(:end_date, "must be after the start date")
    end
  end

  def start_date_cannot_be_in_the_past
    return if start_date.blank?

    if start_date < Date.today
      errors.add(:start_date, "cannot be in the past")
    end
  end

  def no_overlapping_bookings
    return if start_date.blank? || end_date.blank? || listing.blank?

    # Build the query to find overlapping bookings
    overlapping_bookings = listing.bookings
      .where.not(id: id) # Exclude current booking (for updates)
      .where.not(status: [ :cancelled, :rejected ]) # Only check active bookings
      .where("(start_date, end_date) OVERLAPS (?, ?)", start_date, end_date)

    if overlapping_bookings.exists?
      errors.add(:base, "This listing is already booked for the selected dates")
    end
  end
end
