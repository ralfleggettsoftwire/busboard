require 'faraday'

require_relative './BusBoardError'

##
# In future, API calls might be more complicated so define a function
def get_response(request)
  response = Faraday.get(request)

  # If we get a bad response, raise an error
  unless response.status == 200
    errorMsg = "API request to #{request.split('?')[0]} failed. Returned code #{response.status}. "
    errorMsg += "(#{response.reason_phrase}) #{JSON.parse(response.body)['message']}"
    raise APIError, errorMsg
  end

  response
end
