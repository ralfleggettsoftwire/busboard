require "test_helper"

class PostcodeStopsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get postcode_stops_index_url
    assert_response :success
  end
end
