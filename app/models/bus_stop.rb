require_relative './http_tools'

class BusStop < ApplicationRecord
  attr_reader :stop_id, :name

  def initialize(stop_id)
    # Set the stop ID
    @stop_id = stop_id
    @name = ''

    get_stop_data
  end

  ##
  # Fetches info about the stop
  def get_stop_data
    request = "https://api.tfl.gov.uk/StopPoint/#{@stop_id}"
    response = get_response(request)

    json = JSON.parse(response.body)
    @name = json['commonName']
  end

  ##
  # Returns first n expected arrivals at the stop as an array of hashes
  def get_bus_arrivals(number_to_display = 5)
    # Call the TFL API
    request = "https://api.tfl.gov.uk/StopPoint/#{@stop_id}/Arrivals"
    response = get_response(request)

    # Add each arrival to the buses array
    buses = []
    json = JSON.parse(response.body)
    json.each { |bus| buses << get_bus_hash(bus) }

    # Sort by time to arrival
    buses.sort_by!{ |bus| bus[:minutes_to_arrival] }
  end

  ##
  # Parses JSON to extract useful info and returns the hash
  def get_bus_hash(bus)
    {
      destination: bus['destinationName'],
      line_number: bus['lineId'],
      minutes_to_arrival: (bus['timeToStation'] / 60).round
    }
  end
end
