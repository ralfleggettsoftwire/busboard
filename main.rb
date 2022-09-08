require 'json'

require_relative './BusStop'

##
# Gets the nearest stop ID from a given postcode
def stops_from_postcode(postcode, number_to_retrieve: 2)
  # Get response from postcodes API
  response = get_response("https://api.postcodes.io/postcodes/#{postcode.gsub!(/\s*/, '')}")

  # Parse the latitude and longitude
  json = JSON.parse(response.body)
  lat = json['result']['latitude']
  lon = json['result']['longitude']

  # Search for the nearest bus stop
  request = "https://api.tfl.gov.uk/StopPoint/?lat=#{lat}&lon=#{lon}&stopTypes=NaptanPublicBusCoachTram&modes=bus"
  response = get_response(request)

  # Parse the stop ID
  json = JSON.parse(response.body)
  stops = json['stopPoints']

  # Sort by distance
  stops.sort_by!{ |stop| stop['distance'] }.slice(0..number_to_retrieve - 1)
end

##
# Prompt the user to select the program mode
def get_mode
  mode = nil
  loop do
    puts 'Choose mode:'
    puts '  1) Search by stop ID'
    puts '  2) Search by postcode'
    mode = STDIN.gets.chomp
    break if mode.match(/^[1,2]$/)
    puts 'Please enter a valid mode number'
  end
  mode.to_i
end

##
# Search for arrivals by stop ID
def search_by_stop_id
  print 'Please enter a stop ID: '
  stop_id = gets.chomp
  stop = BusStop.new(stop_id)
  stop.get_bus_arrivals
end

##
# Search for arrivals by postcode
def search_by_postcode
  print 'Please enter a postcode: '
  postcode = gets.chomp
  stops = stops_from_postcode(postcode)
  stops.each do |stop|
    puts "Next arrivals for #{stop['commonName']}:"
    stop = BusStop.new(stop['naptanId'])
    stop.get_bus_arrivals
  end
end

def bus_board
  # Rescue API Errors from bad user input gracefully and exit
  begin
    case get_mode
    when 1
      search_by_stop_id
    when 2
      search_by_postcode
    end
  rescue APIError => e
    puts e.message
    exit
  end
end

bus_board