require 'json'

require_relative './bus_stop'
require_relative './postcode_api'
require_relative './tfl_api'

class PostcodeStop < ApplicationRecord
  def initialize(postcode)
    @postcode = postcode
    @postcode_api = PostcodeApi.new
    @tfl_api = TflApi.new
  end

  ##
  # Gets the nearest stop IDs from a given postcode
  def stops_from_postcode(radius)
    # Get latitude and longitude from postcode
    lat, lon = @postcode_api.get_coordinates_from_postcode(@postcode)

    # Get nearest stops from lat and lon
    stops = @tfl_api.get_nearest_busstops(lat, lon, radius)

    # Sort by distance
    stops.sort_by!{ |stop| stop[:distance] }
  end

  ##
  # Gets arrivals from the `number_to_retrieve` nearest stops. Returns an array of hashes
  def get_arrivals(radius, number_to_retrieve)
    # Array to return
    stop_arrivals = []

    # Track how many stops had buses. Stop after processing `number_to_retrieve` of these stops
    stops_with_buses = 0

    # Get arrivals for each stop
    stops_from_postcode(radius).each do |stop|
      # Get arrivals
      bus_stop_obj = BusStop.new(stop[:stop_id])
      arrivals = bus_stop_obj.get_bus_arrivals

      # Add to rval
      stop_arrivals << {
        name: bus_stop_obj.info[:name],
        distance: stop[:distance],
        arrivals: arrivals
      }

      # Check if we need to stop processing
      stops_with_buses += 1 if arrivals.length > 0
      break if stops_with_buses == number_to_retrieve
    end

    stop_arrivals
  end
end
