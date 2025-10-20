require 'rails_helper'

RSpec.describe "Listings", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:listing) { create(:listing, user: user) }

  let(:valid_attributes) do
    {
      title: 'Beautiful Beach House',
      description: 'A wonderful house right on the beach with amazing views and lots of space',
      price_per_night: 150.00,
      bedrooms: 3,
      bathrooms: 2,
      max_guests: 6,
      property_type: 'house',
      address: '123 Beach Road, Miami, FL'
    }
  end

  let(:invalid_attributes) do
    {
      title: 'Bad',
      description: 'Too short',
      price_per_night: -50,
      bedrooms: 0,
      bathrooms: 0,
      max_guests: 0,
      property_type: nil,
      address: nil
    }
  end

  describe 'GET /listings' do
    before do
      create_list(:listing, 5)
    end

    it 'returns http success' do
      get listings_path
      expect(response).to have_http_status(:success)
    end

    it 'renders the index template' do
      get listings_path
      expect(response).to render_template(:index)
    end

    it 'displays all listings' do
      get listings_path
      expect(response.body).to include('listings-grid')
    end

    context 'with pagination' do
      before do
        create_list(:listing, 25)
      end

      it 'paginates results' do
        get listings_path
        expect(assigns(:listings).count).to eq(20)
      end
    end
  end

  describe 'GET /listings/search' do
    let!(:house) { create(:listing, property_type: 'house', title: 'Beach House') }
    let!(:apartment) { create(:listing, property_type: 'apartment', title: 'City Apartment') }
    let!(:expensive) { create(:listing, price_per_night: 500) }
    let!(:cheap) { create(:listing, price_per_night: 50) }

    it 'filters by search query' do
      get search_listings_path, params: { query: 'Beach' }
      expect(response).to have_http_status(:success)
      expect(assigns(:listings)).to include(house)
      expect(assigns(:listings)).not_to include(apartment)
    end

    it 'filters by property type' do
      get search_listings_path, params: { property_type: 'apartment' }
      expect(assigns(:listings)).to include(apartment)
      expect(assigns(:listings)).not_to include(house)
    end

    it 'filters by price range' do
      get search_listings_path, params: { min_price: 100, max_price: 300 }
      expect(assigns(:listings)).not_to include(expensive)
      expect(assigns(:listings)).not_to include(cheap)
    end

    it 'filters by bedrooms' do
      house.update(bedrooms: 3)
      apartment.update(bedrooms: 1)

      get search_listings_path, params: { bedrooms: 2 }
      expect(assigns(:listings)).to include(house)
      expect(assigns(:listings)).not_to include(apartment)
    end

    it 'returns results as HTML' do
      get search_listings_path, params: { query: 'Beach' }
      expect(response.content_type).to match(/html/)
    end
  end

  describe 'GET /listings/:id' do
    it 'returns http success' do
      get listing_path(listing)
      expect(response).to have_http_status(:success)
    end

    it 'renders the show template' do
      get listing_path(listing)
      expect(response).to render_template(:show)
    end

    it 'assigns the requested listing' do
      get listing_path(listing)
      expect(assigns(:listing)).to eq(listing)
    end

    it 'initializes a new booking' do
      get listing_path(listing)
      expect(assigns(:booking)).to be_a_new(Booking)
    end

    it 'loads the listing reviews' do
      review1 = create(:review, listing: listing)
      review2 = create(:review, listing: listing)

      get listing_path(listing)
      expect(assigns(:reviews)).to include(review1, review2)
    end

    context 'when listing does not exist' do
      it 'raises RecordNotFound' do
        expect {
          get listing_path(id: 99999)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'GET /listings/new' do
    context 'when user is authenticated' do
      before { sign_in user }

      it 'returns http success' do
        get new_listing_path
        expect(response).to have_http_status(:success)
      end

      it 'renders the new template' do
        get new_listing_path
        expect(response).to render_template(:new)
      end

      it 'assigns a new listing' do
        get new_listing_path
        expect(assigns(:listing)).to be_a_new(Listing)
        expect(assigns(:listing).user).to eq(user)
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to sign in page' do
        get new_listing_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'POST /listings' do
    context 'when user is authenticated' do
      before { sign_in user }

      context 'with valid parameters' do
        it 'creates a new listing' do
          expect {
            post listings_path, params: { listing: valid_attributes }
          }.to change(Listing, :count).by(1)
        end

        it 'associates the listing with the current user' do
          post listings_path, params: { listing: valid_attributes }
          expect(Listing.last.user).to eq(user)
        end

        it 'redirects to the created listing' do
          post listings_path, params: { listing: valid_attributes }
          expect(response).to redirect_to(listing_path(Listing.last))
        end

        it 'sets a success flash message' do
          post listings_path, params: { listing: valid_attributes }
          follow_redirect!
          expect(response.body).to include('Listing created successfully!')
        end
      end

      context 'with invalid parameters' do
        it 'does not create a new listing' do
          expect {
            post listings_path, params: { listing: invalid_attributes }
          }.not_to change(Listing, :count)
        end

        it 'renders the new template with unprocessable_entity status' do
          post listings_path, params: { listing: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template(:new)
        end

        it 'displays validation errors' do
          post listings_path, params: { listing: invalid_attributes }
          expect(response.body).to include('error')
        end
      end

      context 'with photo attachments' do
        let(:photo) { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg'), 'image/jpeg') }

        it 'attaches photos to the listing' do
          post listings_path, params: { listing: valid_attributes.merge(photos: [ photo ]) }
          expect(Listing.last.photos).to be_attached
        end
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to sign in page' do
        post listings_path, params: { listing: valid_attributes }
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'does not create a listing' do
        expect {
          post listings_path, params: { listing: valid_attributes }
        }.not_to change(Listing, :count)
      end
    end
  end

  describe 'GET /listings/:id/edit' do
    context 'when user is the owner' do
      before { sign_in user }

      it 'returns http success' do
        get edit_listing_path(listing)
        expect(response).to have_http_status(:success)
      end

      it 'renders the edit template' do
        get edit_listing_path(listing)
        expect(response).to render_template(:edit)
      end

      it 'assigns the requested listing' do
        get edit_listing_path(listing)
        expect(assigns(:listing)).to eq(listing)
      end
    end

    context 'when user is not the owner' do
      before { sign_in other_user }

      it 'redirects to root path' do
        get edit_listing_path(listing)
        expect(response).to redirect_to(root_path)
      end

      it 'sets an alert flash message' do
        get edit_listing_path(listing)
        follow_redirect!
        expect(response.body).to include('Not authorized!')
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to sign in page' do
        get edit_listing_path(listing)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'PATCH /listings/:id' do
    let(:new_attributes) do
      {
        title: 'Updated Beach House',
        price_per_night: 200.00
      }
    end

    context 'when user is the owner' do
      before { sign_in user }

      context 'with valid parameters' do
        it 'updates the listing' do
          patch listing_path(listing), params: { listing: new_attributes }
          listing.reload
          expect(listing.title).to eq('Updated Beach House')
          expect(listing.price_per_night).to eq(200.00)
        end

        it 'redirects to the listing' do
          patch listing_path(listing), params: { listing: new_attributes }
          expect(response).to redirect_to(listing_path(listing))
        end

        it 'sets a success flash message' do
          patch listing_path(listing), params: { listing: new_attributes }
          follow_redirect!
          expect(response.body).to include('Listing updated successfully!')
        end
      end

      context 'with invalid parameters' do
        it 'does not update the listing' do
          original_title = listing.title
          patch listing_path(listing), params: { listing: { title: 'Bad' } }
          listing.reload
          expect(listing.title).to eq(original_title)
        end

        it 'renders the edit template with unprocessable_entity status' do
          patch listing_path(listing), params: { listing: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template(:edit)
        end
      end
    end

    context 'when user is not the owner' do
      before { sign_in other_user }

      it 'does not update the listing' do
        original_title = listing.title
        patch listing_path(listing), params: { listing: new_attributes }
        listing.reload
        expect(listing.title).to eq(original_title)
      end

      it 'redirects to root path' do
        patch listing_path(listing), params: { listing: new_attributes }
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to sign in page' do
        patch listing_path(listing), params: { listing: new_attributes }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'DELETE /listings/:id' do
    context 'when user is the owner' do
      before { sign_in user }

      it 'destroys the listing' do
        listing # create the listing
        expect {
          delete listing_path(listing)
        }.to change(Listing, :count).by(-1)
      end

      it 'redirects to the listings index' do
        delete listing_path(listing)
        expect(response).to redirect_to(listings_path)
      end

      it 'sets a success flash message' do
        delete listing_path(listing)
        follow_redirect!
        expect(response.body).to include('Listing deleted successfully!')
      end
    end

    context 'when user is not the owner' do
      before { sign_in other_user }

      it 'does not destroy the listing' do
        listing # create the listing
        expect {
          delete listing_path(listing)
        }.not_to change(Listing, :count)
      end

      it 'redirects to root path' do
        delete listing_path(listing)
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to sign in page' do
        delete listing_path(listing)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  # Turbo-specific tests
  describe 'Turbo Frame requests' do
    context 'when requesting with turbo frame' do
      it 'responds with turbo stream format' do
        get listings_path, headers: { 'Turbo-Frame' => 'listings_results' }
        expect(response).to have_http_status(:success)
      end
    end
  end

  # Helper method tests
  describe 'filtering logic' do
    let!(:listing1) { create(:listing, bedrooms: 2, bathrooms: 1, price_per_night: 100) }
    let!(:listing2) { create(:listing, bedrooms: 4, bathrooms: 3, price_per_night: 300) }

    it 'applies multiple filters simultaneously' do
      get search_listings_path, params: {
        min_price: 50,
        max_price: 150,
        bedrooms: 2
      }

      expect(assigns(:listings)).to include(listing1)
      expect(assigns(:listings)).not_to include(listing2)
    end
  end
end
