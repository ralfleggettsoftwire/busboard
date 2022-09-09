require 'json'

require_relative './bus_board_error'
require_relative './bus_stop'
require_relative './http_tools'

class PostcodeStop < ApplicationRecord
  def initialize(postcode)
    @postcode = postcode
  end

  ##
  # Validates a postcode
  def self.valid_postcode?(postcode)
    # Regex for a UK postcode
    if /^\s*[a-zA-Z]{2}\d[a-zA-Z0-9]?\s*\d[a-zA-Z]{2}\s*$/.match?(postcode)
      response = get_response("https://api.postcodes.io/postcodes/#{postcode}/validate")
      return JSON.parse(response.body)['result']
    end
    false
  end

  ##
  # Gets the nearest stop IDs from a given postcode
  def stops_from_postcode(radius)
    # Get response from postcodes API
    response = get_response("https://api.postcodes.io/postcodes/#{@postcode}")

    # Parse the latitude and longitude
    json = JSON.parse(response.body)
    lat = json['result']['latitude']
    lon = json['result']['longitude']

    # Search for the nearest bus stop
    request = "https://api.tfl.gov.uk/StopPoint/?"
    request += "lat=#{lat}&lon=#{lon}&stopTypes=NaptanPublicBusCoachTram&modes=bus&radius=#{radius}"
    response = get_response(request)

    # Parse the stops
    json = JSON.parse(response.body)
    stops = json['stopPoints']

    # Sort by distance
    stops.sort_by!{ |stop| stop['distance'] }
  end

  ##
  # Gets arrivals from the `number_to_retrieve` nearest stops. Returns an array of hashes
  def get_arrivals(radius, number_to_retrieve)
    # Get stops for postcode
    stops_json = stops_from_postcode(radius)

    # Array to return
    rval = []

    # Track how many stops had buses. Stop after processing `number_to_retrieve` of these stops
    stops_with_buses = 0
    stops_json.each do |stop_json|
      # Get arrivals
      bus_stop_obj = BusStop.new(stop_json['naptanId'])
      arrivals = bus_stop_obj.get_bus_arrivals

      # Add to rval
      rval << {
        name: bus_stop_obj.name,
        arrivals: arrivals
      }

      # Check if we need to stop processing
      stops_with_buses += 1 if arrivals.length > 0
      break if stops_with_buses == number_to_retrieve
    end

    rval
  end
end
