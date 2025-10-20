class ListingsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show, :search ]
  before_action :set_listing, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_owner!, only: [ :edit, :update, :destroy ]

  def index
    @pagy, @listings = pagy(Listing.all, items: 20)
  end

  def search
    binding.break
    @listings = Listing.all
    @listings = @listings.where("title ILIKE ? OR address ILIKE ?", "%#{params[:query]}%", "%#{params[:query]}%") if params[:query].present?
    @listings = @listings.price_range(params[:min_price], params[:max_price]) if params[:min_price] && params[:max_price]
    @listings = @listings.by_property_type(params[:property_type]) if params[:property_type].present?
    @listings = @listings.by_rooms(params[:bedrooms]) if params[:bedrooms].present?

    @pagy, @listings = pagy(@listings, items: 20)

    render :index
  end

  def show
    @reviews = @listing.reviews.includes(:user).order(created_at: :desc)
    @booking = Booking.new
  end

  def new
    @listing = current_user.listings.build
  end

  def create
    @listing = current_user.listings.build(listing_params)

    if @listing.save
      redirect_to @listing, notice: "Listing created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @listing.update(listing_params)
      redirect_to @listing, notice: "Listing updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @listing.destroy
    redirect_to listings_path, notice: "Listing deleted successfully!"
  end

  private

  def set_listing
    @listing = Listing.find(params[:id])
  end

  def authorize_owner!
    redirect_to root_path, alert: "Not authorized!" unless @listing.user == current_user
  end

  def listing_params
    params.require(:listing).permit(
      :title, :description, :price_per_night,
      :bedrooms, :bathrooms, :max_guests,
      :property_type, :address, :latitude, :longitude,
      photos: []
    )
  end
end
