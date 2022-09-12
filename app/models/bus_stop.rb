require_relative './tfl_api'

class BusStop < ApplicationRecord
  attr_reader :stop_id, :info

  def initialize(stop_id)
    # Set the stop ID
    @stop_id = stop_id
    @tfl_api = TflApi.new
    @info = @tfl_api.get_stop_info(@stop_id)
  end

  ##
  # Returns first n expected arrivals at the stop as an array of hashes
  def get_bus_arrivals(number_to_display = 5)
    buses = @tfl_api.get_arrival_info(@stop_id).first(number_to_display)

    # Sort by time to arrival
    buses.sort_by!{ |bus| bus[:minutes_to_arrival] }
  end
end
