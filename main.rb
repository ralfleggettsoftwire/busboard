require 'json'

require_relative './BusStop'
require_relative './PostcodeStops'

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
# Search for arrivals by postcode
def search_by_postcode(radius: 200, number_to_retrieve: 2)
  postcode_stops = get_postcode
  found_stops = postcode_stops.get_arrivals(radius, number_to_retrieve)

  if !found_stops
    # TODO prompt user to increase radius
  end
end

##
# Gets postcode from user. Loops until valid postcode supplied. Returns PostcodeStops object
def get_postcode
  while true
    begin
      print 'Enter a postcode: '
      postcode = gets.chomp.gsub!(/\s*/, '')
      return PostcodeStops.new(postcode)
    rescue InvalidPostcodeError => e
      puts e.message
    end
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