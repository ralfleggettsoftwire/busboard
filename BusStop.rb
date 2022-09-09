require_relative './BusArrival'
require_relative './http_tools'

class BusStop
  attr_reader :stop_id

  def initialize(stop_id)
    # Set the stop ID
    @stop_id = stop_id
  end

  ##
  # Prints first n expected arrivals at the stop. Returns true if buses were found
  def get_bus_arrivals(number_to_display = 5)
    # Call the TFL API
    request = "https://api.tfl.gov.uk/StopPoint/#{@stop_id}/Arrivals"
    response = get_response(request)

    # Add each arrival to the buses array
    buses = []
    json = JSON.parse(response.body)
    json.each { |bus| buses << BusArrival.new(bus) }

    # Sort by time to arrival
    buses.sort_by!{ |bus| bus.seconds_to_arrival }

    # Pretty print
    if buses.length > 0
      (0..[number_to_display - 1, buses.length - 1].min).each { |i| buses[i].pretty_print }
    else
      puts "  No arrivals for this stop"
    end

    # Indicate if buses were found
    return buses.length > 0
  end
end