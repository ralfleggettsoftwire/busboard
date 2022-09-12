require 'faraday'

require_relative './bus_board_error'

class BaseApi < ApplicationRecord
  ##
  # Fetches the response for a given HTTP request. Raises errors depending on the status of the response.
  def get_response(request)
    response = Faraday.get(request)

    # If we get a bad response, raise an error
    unless response.status == 200
      if response.status == 404
        errorMsg = "API request to #{request.split('?')[0]} failed. Returned code #{response.status}. "
        errorMsg += "(#{response.reason_phrase}) #{JSON.parse(response.body)['message']}"
        raise NotFoundError.new, errorMsg
      else
        errorMsg = "API request to #{request.split('?')[0]} failed. Returned code #{response.status}. "
        errorMsg += "(#{response.reason_phrase}) #{JSON.parse(response.body)['message']}"
        raise APIError.new, errorMsg
      end
    end

    response
  end
end
