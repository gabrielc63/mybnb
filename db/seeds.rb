# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Cleaning database..."
  Review.destroy_all
  Booking.destroy_all
  Listing.destroy_all
  User.destroy_all

  puts "Creating users..."

  # Create host users with realistic data
  hosts = []

  10.times do |i|
    host = User.create!(
      email: "host#{i + 1}@mybnb.com",
      password: "password123",
      name: Faker::Name.name
    )
    hosts << host
    puts "  Created user: #{host.name} (#{host.email})"
  end

  # Create a demo user for testing
  demo_user = User.create!(
    email: "demo@mybnb.com",
    password: "password123",
    name: "Demo User"
  )
  puts "  Created demo user: #{demo_user.email}"

  puts "\nCreating listings..."

  # Define property type specific data
  property_data = {
    house: {
      titles: [
        "Charming Family House",
        "Spacious Modern Home",
        "Cozy Suburban House",
        "Elegant Victorian House",
        "Contemporary Beach House",
        "Rustic Country Home",
        "Luxurious Villa House",
        "Traditional Family Home"
      ],
      bedrooms: [ 3, 4, 5, 6 ],
      bathrooms: [ 2, 3, 4 ],
      price_range: 150..500
    },
    apartment: {
      titles: [
        "Downtown Loft Apartment",
        "Stylish City Apartment",
        "Modern Studio Apartment",
        "Penthouse Apartment",
        "Cozy Urban Apartment",
        "Bright & Airy Apartment",
        "Chic Downtown Flat",
        "Luxury High-Rise Apartment"
      ],
      bedrooms: [ 1, 2, 3 ],
      bathrooms: [ 1, 2 ],
      price_range: 80..300
    },
    villa: {
      titles: [
        "Oceanfront Luxury Villa",
        "Private Estate Villa",
        "Mediterranean Style Villa",
        "Tropical Paradise Villa",
        "Hillside Retreat Villa",
        "Exclusive Beach Villa",
        "Mountain View Villa",
        "Modern Architectural Villa"
      ],
      bedrooms: [ 4, 5, 6, 7 ],
      bathrooms: [ 3, 4, 5 ],
      price_range: 400..1200
    },
    cabin: {
      titles: [
        "Rustic Mountain Cabin",
        "Lakefront Log Cabin",
        "Secluded Forest Cabin",
        "Cozy Winter Cabin",
        "Charming Woodland Retreat",
        "Remote Wilderness Cabin",
        "Peaceful Countryside Cabin",
        "Alpine Ski Cabin"
      ],
      bedrooms: [ 2, 3, 4 ],
      bathrooms: [ 1, 2 ],
      price_range: 100..350
    },
    guesthouse: {
      titles: [
        "Private Garden Guesthouse",
        "Charming Cottage Guesthouse",
        "Quiet Backyard Guesthouse",
        "Boutique Guesthouse",
        "Historic Guesthouse",
        "Modern Guest Suite",
        "Peaceful Retreat Guesthouse",
        "Elegant Guest Villa"
      ],
      bedrooms: [ 1, 2 ],
      bathrooms: [ 1, 2 ],
      price_range: 70..200
    },
    hotel: {
      titles: [
        "Boutique Hotel Room",
        "Luxury Hotel Suite",
        "Modern Hotel Accommodation",
        "Premium Hotel Room",
        "Executive Hotel Suite",
        "Deluxe Hotel Room",
        "Business Hotel Suite",
        "Elegant Hotel Apartment"
      ],
      bedrooms: [ 1, 2 ],
      bathrooms: [ 1, 2 ],
      price_range: 90..400
    }
  }

  # Cities with coordinates for realistic locations
  locations = [
    { city: "Miami", state: "FL", country: "USA", lat: 25.7617, lng: -80.1918 },
    { city: "Los Angeles", state: "CA", country: "USA", lat: 34.0522, lng: -118.2437 },
    { city: "New York", state: "NY", country: "USA", lat: 40.7128, lng: -74.0060 },
    { city: "San Francisco", state: "CA", country: "USA", lat: 37.7749, lng: -122.4194 },
    { city: "Austin", state: "TX", country: "USA", lat: 30.2672, lng: -97.7431 },
    { city: "Seattle", state: "WA", country: "USA", lat: 47.6062, lng: -122.3321 },
    { city: "Denver", state: "CO", country: "USA", lat: 39.7392, lng: -104.9903 },
    { city: "Portland", state: "OR", country: "USA", lat: 45.5152, lng: -122.6784 },
    { city: "Nashville", state: "TN", country: "USA", lat: 36.1627, lng: -86.7816 },
    { city: "Charleston", state: "SC", country: "USA", lat: 32.7765, lng: -79.9311 }
  ]

  # Description templates
  description_templates = [
    "Welcome to our beautiful %{property}! This stunning property features %{feature1} and %{feature2}. Perfect for %{perfect_for}, you'll love the %{highlight}. The space
  is %{space_desc} and includes all modern amenities. Located in the heart of %{location}, you're just minutes away from %{nearby}.",

    "Experience luxury in this %{property}. Boasting %{feature1}, this property offers %{feature2}. Ideal for %{perfect_for}, the %{highlight} will make your stay
  unforgettable. The %{space_desc} space provides everything you need for a comfortable visit. Situated in %{location}, enjoy easy access to %{nearby}.",

    "Discover your perfect getaway in our %{property}. Featuring %{feature1} and %{feature2}, this retreat is designed for %{perfect_for}. You'll appreciate the %{highlight}
   and the %{space_desc} layout. Located in %{location}, you're conveniently close to %{nearby}.",

    "Unwind in this exceptional %{property} that showcases %{feature1} alongside %{feature2}. Tailored for %{perfect_for}, the property's %{highlight} sets it apart. The
  %{space_desc} interior ensures a memorable stay. Nestled in %{location}, explore nearby %{nearby} with ease."
  ]

  features = [
    "spacious living areas", "modern kitchen", "private pool", "stunning views",
    "outdoor patio", "gourmet kitchen", "home office", "entertainment system",
    "designer furnishings", "walk-in closets", "spa-like bathrooms", "hardwood floors",
    "floor-to-ceiling windows", "private balcony", "fireplace", "gym access"
  ]

  perfect_for_options = [
    "families", "couples", "business travelers", "groups",
    "weekend getaways", "long-term stays", "remote workers", "vacationers"
  ]

  highlights = [
    "spectacular sunset views", "peaceful atmosphere", "prime location",
    "attention to detail", "luxurious amenities", "thoughtful design",
    "exceptional comfort", "unique character", "breathtaking scenery"
  ]

  space_descriptions = [
    "open-concept", "beautifully decorated", "meticulously maintained",
    "bright and welcoming", "elegantly appointed", "thoughtfully designed",
    "spacious and comfortable", "stylishly furnished"
  ]

  nearby_attractions = [
    "restaurants and shops", "beaches", "downtown attractions",
    "hiking trails", "entertainment venues", "cultural sites",
    "local attractions", "nightlife", "shopping districts"
  ]

  # Create 50 listings with variety
  listings_created = 0

  property_data.each do |property_type, data|
    # Create 8-9 listings per property type
    8.times do
      location = locations.sample
      title = data[:titles].sample

      # Generate realistic description
      description = description_templates.sample % {
        property: property_type.to_s.gsub('_', ' '),
        feature1: features.sample,
        feature2: features.sample,
        perfect_for: perfect_for_options.sample,
        highlight: highlights.sample,
        space_desc: space_descriptions.sample,
        location: location[:city],
        nearby: nearby_attractions.sample
      }

      bedrooms = data[:bedrooms].sample
      bathrooms = data[:bathrooms].sample
      max_guests = bedrooms * 2 + rand(1..2)
      price_per_night = rand(data[:price_range])

      # Add slight randomness to coordinates
      latitude = location[:lat] + (rand(-100..100) / 1000.0)
      longitude = location[:lng] + (rand(-100..100) / 1000.0)

      street_number = rand(100..9999)
      street_name = Faker::Address.street_name
      address = "#{street_number} #{street_name}, #{location[:city]}, #{location[:state]}"

      listing = Listing.create!(
        user: hosts.sample,
        title: title,
        description: description,
        price_per_night: price_per_night,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        max_guests: max_guests,
        property_type: property_type,
        address: address,
        latitude: latitude,
        longitude: longitude
      )

      listings_created += 1
      puts "  Created listing #{listings_created}: #{listing.title} in #{location[:city]} ($#{listing.price_per_night}/night) with #{listing.photos.count} photos"
    end
  end

  # Create some bookings
  all_listings = Listing.all
  bookings_created = 0

  50.times do
    listing = all_listings.sample
    guest = ([ demo_user ] + hosts).sample

    # Skip if guest is the host of the listing
    next if guest == listing.user

    # Determine status first to set appropriate dates
    status = [ :pending, :confirmed, :completed, :cancelled, :rejected ].sample

    # For completed bookings, use past dates; for others, use future dates
    if status == :completed
      start_date = Faker::Date.between(from: 60.days.ago, to: 10.days.ago)
    else
      start_date = Faker::Date.between(from: Date.today, to: 60.days.from_now)
    end

    duration = rand(2..10)
    end_date = start_date + duration.days

    booking = Booking.new(
      user: guest,
      listing: listing,
      start_date: start_date,
      end_date: end_date,
      guests_amount: rand(1..listing.max_guests),
      special_requests: [ nil, "Early check-in please", "Need parking space", "Celebrating anniversary" ].sample,
      status: status,
      final_price: listing.price_per_night * duration
    )

    # For completed bookings with past dates, save without validation to bypass date validation
    # For cancelled/rejected, also skip validation as they might overlap (but that's okay)
    if (status == :completed && start_date < Date.today) || [ :cancelled, :rejected ].include?(status)
      booking.save(validate: false)
      bookings_created += 1
      puts "  Created booking #{bookings_created}: #{booking.listing.title} for #{booking.user.name} (#{status})"
    else
      # For pending/confirmed bookings, validate to prevent overlaps
      if booking.save
        bookings_created += 1
        puts "  Created booking #{bookings_created}: #{booking.listing.title} for #{booking.user.name} (#{status})"
      else
        # Skip this booking if it overlaps with existing ones
        puts "  Skipped overlapping booking for #{listing.title}"
      end
    end
  end

  puts "\nCreating reviews..."

  # Create reviews for completed bookings
  completed_bookings = Booking.where(status: :completed)
  reviews_created = 0

  completed_bookings.each do |booking|
    next if rand > 0.7 # Only 70% of completed bookings have reviews

    review_comments = [
      "Amazing place! Everything was as described and the host was very responsive. Would definitely stay again!",
      "Great location and beautiful property. Very clean and comfortable. Highly recommend!",
      "Perfect getaway spot. The photos don't do it justice - it's even better in person!",
      "Wonderful stay! The place had everything we needed and more. Very convenient location.",
      "Lovely property with great amenities. The host was super helpful and accommodating.",
      "Excellent experience overall. Clean, comfortable, and exactly what we were looking for.",
      "Beautiful space in a great neighborhood. Would love to come back!",
      "Very nice property! Well-maintained and the check-in process was smooth.",
      "Fantastic location and the property exceeded our expectations. Highly recommended!",
      "Had a great time! The place was spotless and had all the comforts of home."
    ]

    review = Review.create!(
      user: booking.user,
      listing: booking.listing,
      rating: rand(3..5),
      comment: review_comments.sample
    )

    reviews_created += 1
    puts "  Created review #{reviews_created}: #{review.rating} stars for #{review.listing.title}"
  end

  puts "\n" + "="*50
  puts "Seed data created successfully!"
  puts "="*50
  puts "Users created: #{User.count}"
  puts "  - Hosts: #{hosts.count}"
  puts "  - Demo user: #{demo_user.email} / password123"
  puts "Listings created: #{Listing.count}"
  puts "  - Houses: #{Listing.where(property_type: :house).count}"
  puts "  - Apartments: #{Listing.where(property_type: :apartment).count}"
  puts "  - Villas: #{Listing.where(property_type: :villa).count}"
  puts "  - Cabins: #{Listing.where(property_type: :cabin).count}"
  puts "  - Guesthouses: #{Listing.where(property_type: :guesthouse).count}"
  puts "  - Hotels: #{Listing.where(property_type: :hotel).count}"
  puts "Bookings created: #{Booking.count}"
  puts "Reviews created: #{Review.count}"
  puts "="*50
  puts "\nYou can login with:"
  puts "  Email: demo@mybnb.com"
  puts "  Password: password123"
  puts "\nOr any host account:"
  puts "  Email: host1@mybnb.com (through host10@mybnb.com)"
  puts "  Password: password123"
  puts "="*50
