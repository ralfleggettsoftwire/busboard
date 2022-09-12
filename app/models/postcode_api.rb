require 'json'

require_relative './http_tools'

##
# Manages interactions with the postcodes.io API. Abstracts the API so that if there are any changes to it,
# # the only adjustments that need to be made are in this file
class PostcodeApi < ApplicationRecord
  ##
  # Gets the latitude and longitude for a postcode
  def get_coordinates_from_postcode(postcode)
    # Get response from postcodes API
    response = get_response("https://api.postcodes.io/postcodes/#{postcode}")

    # Parse the latitude and longitude
    json = JSON.parse(response.body)
    [json['result']['latitude'], json['result']['longitude']]
  end

  ##
  # Validates a postcode
  def self.valid_postcode?(postcode)
    # Regex for a UK postcode
    if /^\s*[a-zA-Z0-9]{,4}\s*\d[a-zA-Z]{2}\s*$/.match?(postcode)
      response = get_response("https://api.postcodes.io/postcodes/#{postcode}/validate")
      return JSON.parse(response.body)['result']
    end
    false
  end
end
