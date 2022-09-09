require 'faraday'

require_relative './bus_board_error'

def get_response(request)
  response = Faraday.get(request)

  # If we get a bad response, raise an error
  unless response.status == 200
    if response.status == 404
      errorMsg = "API request to #{request.split('?')[0]} failed. Returned code #{response.status}. "
      errorMsg += "(#{response.reason_phrase}) #{JSON.parse(response.body)['message']}"
      raise NotFoundError.new(response.status), errorMsg
    else
      errorMsg = "API request to #{request.split('?')[0]} failed. Returned code #{response.status}. "
      errorMsg += "(#{response.reason_phrase}) #{JSON.parse(response.body)['message']}"
      raise APIError.new(response.status), errorMsg
    end
  end

  response
end
