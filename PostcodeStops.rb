require 'json'

require_relative './BusBoardError'
require_relative './BusStop'
require_relative './http_tools'

class PostcodeStops
  def initialize(postcode)
    # Assert postcode is valid
    unless valid_postcode?(postcode)
      raise InvalidPostcodeError, "#{postcode} is not a valid postcode"
    end

    @postcode = postcode
  end

  ##
  # Validates a postcode
  def valid_postcode?(postcode)
    # Regex avoids bad URLs
    if /^\w{,10}$/.match?(postcode)
      response = get_response("https://api.postcodes.io/postcodes/#{postcode}/validate")
      return JSON.parse(response.body)['result']
    end
    false
  end

  ##
  # Gets the nearest stop ID from a given postcode
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
  # Gets arrivals from the `number_to_retrieve` nearest stops. Returns true if stops were found
  def get_arrivals(radius, number_to_retrieve)
    # Get stops for postcode
    stops = stops_from_postcode(radius)

    # List the stops or, if there are none, alert the user
    if stops.length > 0
      # Track how many stops had buses. Stop after printing `number_to_retrieve` of these stops
      stops_with_buses = 0
      stops.each do |stop|
        # Print the arrivals
        puts "Next arrivals for #{stop['commonName']}:"
        stop = BusStop.new(stop['naptanId'])
        found_buses = stop.get_bus_arrivals

        # Check if we need to stop printing
        stops_with_buses += 1 if found_buses
        break if stops_with_buses == number_to_retrieve
      end
    else
      puts "No stops found for this postcode within #{radius}m"
    end

    stops.length > 0
  end
end

