class BusBoardError < ::StandardError

end

class APIError < BusBoardError
  def initialize(status)
    @status = status
  end
end

class NotFoundError < APIError

end
