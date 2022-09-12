class BusBoardError < ::StandardError

end

class APIError < BusBoardError

end

class NotFoundError < APIError

end

class InvalidPostcodeError < BusBoardError

end