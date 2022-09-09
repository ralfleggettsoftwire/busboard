require "test_helper"

class ChooseActionControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get choose_action_index_url
    assert_response :success
  end
end
