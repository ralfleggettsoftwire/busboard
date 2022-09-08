##
# Holds information for a single arriving bus
class BusArrival
  attr_reader :destination, :line_number, :seconds_to_arrival

  def initialize(json)
    @destination = json['destinationName']
    @line_number = json['lineId']
    @seconds_to_arrival = json['timeToStation']
  end

  def get_minutes_to_arrival
    (@seconds_to_arrival / 60).round
  end

  def pretty_print
    puts "  Line ID #{@line_number} to #{@destination} in #{get_minutes_to_arrival} minutes."
  end
end