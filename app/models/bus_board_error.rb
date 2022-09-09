class BusBoardError < ::StandardError

end

class APIError < BusBoardError
  def initialize(status)
    super
    @status = status
  end
end

class NotFoundError < APIError

end

class InvalidPostcodeError < BusBoardError

end
