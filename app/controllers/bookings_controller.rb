class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_listing

  def new
    @booking = @listing.bookings.build
  end

  def create
    @booking = @listing.bookings.build(booking_params)
    @booking.user = current_user

    if @booking.save
      redirect_to @listing, notice: "Booking request submitted successfully!"
    else
      redirect_to @listing, alert: "Unable to create booking: #{@booking.errors.full_messages.join(', ')}"
    end
  end

  private

  def set_listing
    @listing = Listing.find(params[:listing_id])
  end

  def booking_params
    params.require(:booking).permit(:start_date, :end_date, :guests_amount)
  end
end
