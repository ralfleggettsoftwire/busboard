class StopIdArrivalsController < ApplicationController
  def initialize
    @stop_id = ''
    @errors = []
    @data = {}
    @retrieval_time = nil
  end

  def index
    @retrieval_time = Time.now

    @stop_id = params[:stop_id].gsub(/\s*/, '').upcase

    # Get BusStop object; may return NotFoundError if supplied stop_id is not found
    begin
      bus_stop = BusStop.new(@stop_id)
      @data[:name] = bus_stop.info[:name]
      @data[:arrivals] = bus_stop.get_bus_arrivals
    rescue NotFoundError => e
      @errors << "Could not find a bus stop with ID #{@stop_id}"
    end
  end
end
