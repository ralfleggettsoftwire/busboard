require 'json'

require_relative './BusStop'

##
# Gets the nearest stop ID from a given postcode
def stops_from_postcode(postcode, radius, number_to_retrieve: 2)
  # Get response from postcodes API
  response = get_response("https://api.postcodes.io/postcodes/#{postcode}")

  # Parse the latitude and longitude
  json = JSON.parse(response.body)
  lat = json['result']['latitude']
  lon = json['result']['longitude']

  # Search for the nearest bus stop
  request = "https://api.tfl.gov.uk/StopPoint/?lat=#{lat}&lon=#{lon}&stopTypes=NaptanPublicBusCoachTram&modes=bus&radius=#{radius}"
  response = get_response(request)

  # Parse the stops
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
    puts 'Available modes:'
    puts '  1) Search by stop ID'
    puts '  2) Search by postcode'
    print 'Select a mode: '
    mode = STDIN.gets.chomp
    break if mode.match(/^[1,2]$/)
    puts 'Please enter a valid mode number'
  end
  mode.to_i
end

##
# Search for arrivals by stop ID
def search_by_stop_id
  begin
    print 'Please enter a stop ID: '
    stop_id = gets.chomp
    stop = BusStop.new(stop_id)
    stop.get_bus_arrivals
  rescue NotFoundError => e
    puts 'Stop ID not found. Please enter a valid ID'
    search_by_stop_id
  end
end

##
# Gets a postcode from the user and validates it. Loops until valid postcode supplied
def get_postcode
  while true
    # Get postcode from user and strip whitespace
    print 'Please enter a postcode: '
    postcode = gets.chomp.gsub!(/\s*/, '')

    # Test if the postcode is valid. Regex avoids bad URLs
    if /^\w{,10}$/.match?(postcode)
      response = get_response("https://api.postcodes.io/postcodes/#{postcode}/validate")
      if JSON.parse(response.body)['result']
        return postcode
      end
    end

    puts 'Please enter a valid postcode'
  end
end

##
# Search for arrivals by postcode
def search_by_postcode(postcode, radius: 200)
  # Get stops for postcode
  stops = stops_from_postcode(postcode, radius)

  # List the stops or, if there are none, alert the user
  if stops.length > 0
    stops.each do |stop|
      puts "Next arrivals for #{stop['commonName']}:"
      stop = BusStop.new(stop['naptanId'])
      stop.get_bus_arrivals
    end
  else
    puts "No buses found for this postcode within #{radius}m"
  end
end

def bus_board
  # Rescue API Errors from bad user input gracefully and exit
  begin
    case get_mode
    when 1
      search_by_stop_id
    when 2
      postcode = get_postcode
      search_by_postcode(postcode)
    end
  rescue APIError => e
    puts e.message
    exit
  end
end

bus_board