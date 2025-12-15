# frozen_string_literal: true

require 'net/http'
require 'json'

class GoogleReviewsService
  PLACE_DETAILS_URL = 'https://maps.googleapis.com/maps/api/place/details/json'
  CACHE_KEY = 'google_reviews'
  CACHE_EXPIRY = 24.hours

  def self.fetch_reviews
    cached_reviews = Rails.cache.read(CACHE_KEY)
    return cached_reviews if cached_reviews.present?

    reviews = fetch_from_api
    Rails.cache.write(CACHE_KEY, reviews, expires_in: CACHE_EXPIRY) if reviews.present?
    reviews
  rescue StandardError => e
    Rails.logger.error("Failed to fetch Google reviews: #{e.message}")
    []
  end

  def self.fetch_from_api
    api_key = ENV['GOOGLE_PLACES_API_KEY']
    place_id = ENV['GOOGLE_PLACE_ID']

    return [] if api_key.blank? || place_id.blank?

    uri = URI(PLACE_DETAILS_URL)
    params = {
      place_id: place_id,
      fields: 'reviews',
      key: api_key
    }
    uri.query = URI.encode_www_form(params)

    response = Net::HTTP.get_response(uri)

    return [] unless response.is_a?(Net::HTTPSuccess)

    data = JSON.parse(response.body)

    return [] unless data['status'] == 'OK' && data['result'].present?

    reviews = data['result']['reviews'] || []

    # Map to a simpler structure
    reviews.map do |review|
      {
        author_name: review['author_name'],
        rating: review['rating'],
        text: review['text'],
        time: Time.at(review['time']),
        profile_photo_url: review['profile_photo_url'],
        relative_time_description: review['relative_time_description']
      }
    end
  end

  def self.clear_cache
    Rails.cache.delete(CACHE_KEY)
  end
end
