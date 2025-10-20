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
  # Review.destroy_all
  # Booking.destroy_all
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
      puts "  Created listing #{listings_created}: #{listing.title} in #{location[:city]} ($#{listing.price_per_night}/night)"
    end
  end
