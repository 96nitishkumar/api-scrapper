require 'httparty'

EARCH_LATITUDE = 40.7127753
SEARCH_LONGITUDE = -74.0059728
SEARCH_RADIUS = 8.045
RESULT_LIMIT = 30
COUNTRY_CODE = 'us'
LOCALE = 'en-us'
HTTP_USER_AGENT = 'Mozilla/5.0 (compatible)'

def compose_full_address(location_info)
  [
    location_info['addressLine1'],
    location_info['addressLine3'],
    location_info['subDivision'],
    location_info['postcode'],
    location_info['addressLine4']
  ].compact.join(', ')
end

def retrieve_outlets
  api_endpoint = 'https://www.mcdonalds.com/googleappsv2/geolocation'
  params = {
    latitude: SEARCH_LATITUDE,
    longitude: SEARCH_LONGITUDE,
    radius: SEARCH_RADIUS,
    maxResults: RESULT_LIMIT,
    country: COUNTRY_CODE,
    language: LOCALE
  }

  headers = { 'User-Agent' => HTTP_USER_AGENT }

  response = HTTParty.get(api_endpoint, query: params, headers: headers)

  unless response.success?
    raise "Failed to fetch outlet data. HTTP Status: #{response.code}"
  end

  response['features'] || []
end

# outlet scrapper
def outlet_info
  puts "Starting data retrieval from McDonald's API...\n\n"

  outlets_collection = {}

  retrieve_outlets.each_with_index do |feature, index|
    properties = feature['properties']
    coords = feature.dig('geometry', 'coordinates') || []

    outlets_collection["Outlet_#{index + 1}"] = {
      name: properties['addressLine1'],
      longitude: coords[0],
      latitude: coords[1],
      contact_number: properties['telephone'],
      full_address: compose_full_address(properties)
    }
  end

  puts "Data retrieval completed successfully.\n\n"
  outlets_collection
end


results = outlet_info
puts "Scraped Outlet Data:\n\n"
puts results
