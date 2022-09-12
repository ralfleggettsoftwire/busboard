require('date')

class PostcodeArrivalsController < ApplicationController
  def initialize
    @postcode = ''
    @pretty_postcode = ''   # Nicely formatted
    @errors = []
    @data = {}
    @radius = 200
    @number_to_retrieve = 2
    @retrieval_time = nil
  end

  def index
    @retrieval_time = Time.now

    @postcode = params[:postcode].gsub(/\s*/, '')
    unless PostcodeApi.valid_postcode?(@postcode)
      @errors << "#{@postcode} is not a valid postcode."
      @pretty_postcode = @postcode
      return
    end

    prettify_postcode

    postcode_stop = PostcodeStop.new(@postcode)
    stop_data = postcode_stop.get_arrivals(@radius, @number_to_retrieve)
    @data[:stop_data] = stop_data
  end

  private def prettify_postcode
    @pretty_postcode = @postcode.slice(..-4).upcase
    @pretty_postcode += " "
    @pretty_postcode += @postcode.slice(-3..).upcase
  end
end
