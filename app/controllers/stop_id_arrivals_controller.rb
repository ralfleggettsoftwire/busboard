class StopIdArrivalsController < ApplicationController
  def initialize
    @stop_id = ''
    @errors = []
    @data = {}
  end

  def index
    @stop_id = params[:stop_id].gsub(/\s*/, '').upcase

    # Get BusStop object; may return NotFoundError if supplied stop_id is not found
    bus_stop = nil
    begin
      bus_stop = BusStop.new(@stop_id)
    rescue NotFoundError => e
      @errors << "Could not find a bus stop with ID #{@stop_id}"
      return
    end

    @data[:name] = bus_stop.name
    @data[:arrivals] = bus_stop.get_bus_arrivals
  end
end
