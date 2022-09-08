require_relative './BusArrival'

class BusStop
  attr_reader :buses

  def initialize(json)
    @buses = []
    json.each { |bus| buses << BusArrival.new(bus) }

    # Sort by time to arrival
    buses.sort_by!{ |bus| bus.seconds_to_arrival }
  end

  def pretty_print(number_to_display = 5)
    (0..number_to_display - 1).each { |i| buses[i].pretty_print}
  end

end