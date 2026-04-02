# test_google_reviews.rb
require_relative "config/environment"

puts "Testing Google Reviews Service..."
puts "GOOGLE_PLACE_ID: #{ENV['GOOGLE_PLACE_ID']}"
puts "GOOGLE_PLACES_API_KEY: #{ENV['GOOGLE_PLACES_API_KEY'] ? 'PRESENT' : 'MISSING'}"

reviews = GoogleReviewsService.fetch_from_api
puts "Reviews fetched (from API): #{reviews.inspect}"

if reviews.empty?
  # Let's try to see why
  api_key = ENV["GOOGLE_PLACES_API_KEY"]
  place_id = ENV["GOOGLE_PLACE_ID"]
  uri = URI("https://maps.googleapis.com/maps/api/place/details/json")
  params = {
    place_id: place_id,
    fields: "reviews",
    key: api_key
  }
  uri.query = URI.encode_www_form(params)
  response = Net::HTTP.get_response(uri)
  puts "HTTP Status: #{response.code}"
  puts "Body: #{response.body}"
end
