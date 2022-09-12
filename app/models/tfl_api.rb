require 'json'

require_relative './http_tools'

##
# Manages interactions with the TFL API. Abstracts the API so that if there are any changes to it,
# the only adjustments that need to be made are in this file
class TflApi < ApplicationRecord
  ##
  # Gets bus stops within radius metres of a latitude, longitude coordinate
  def get_nearest_busstops(lat, lon, radius)
    # Search for the nearest bus stop
    request = "https://api.tfl.gov.uk/StopPoint/?"
    request += "lat=#{lat}&lon=#{lon}&stopTypes=NaptanPublicBusCoachTram&modes=bus&radius=#{radius}"
    response = get_response(request)

    # Parse the stops
    nearest_busstops = []
    json = JSON.parse(response.body)
    json['stopPoints'].each do |stop|
      nearest_busstops << {
        stop_id: stop['naptanId'],
        distance: stop['distance']
      }
    end
    nearest_busstops
  end

  ##
  # Gets info about a stop using its stop ID
  def get_stop_info(stop_id)
    request = "https://api.tfl.gov.uk/StopPoint/#{stop_id}"
    response = get_response(request)
    info = JSON.parse(response.body)

    # Info to return:
    {
      name: info['commonName']
    }
  end

  ##
  # Gets info about arrivals at a bus stop
  def get_arrival_info(stop_id)
    arrival_info = []

    request = "https://api.tfl.gov.uk/StopPoint/#{stop_id}/Arrivals"
    response = get_response(request)
    JSON.parse(response.body).each do |bus|
      arrival_info << {
        destination: bus['destinationName'],
        line_number: bus['lineId'],
        minutes_to_arrival: (bus['timeToStation'] / 60).round
      }
    end

    arrival_info
  end
end
