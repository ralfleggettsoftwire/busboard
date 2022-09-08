require 'json'
require 'faraday'

require_relative './BusStop'

def construct_request(stop_id)
  "https://api.tfl.gov.uk/StopPoint/#{stop_id}/Arrivals"
end

def get_response(request)
  response = Faraday.get(request)
  if response.status == 200
    return response
  else
    puts "Request returned code #{response.status}"
    puts JSON.parse(response.body)['message']
    puts 'Exiting...'
    exit
  end
end

def bus_board
  print 'Please enter a stop ID: '
  stop_id = gets.chomp

  request = construct_request(stop_id)
  response = get_response(request)

  raw_json = JSON.parse(response.body)
  bus_stop = BusStop.new(raw_json)

  bus_stop.pretty_print
end

bus_board