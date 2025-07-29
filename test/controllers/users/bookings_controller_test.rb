require "test_helper"

class Users::BookingsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get users_bookings_index_url
    assert_response :success
  end
end
