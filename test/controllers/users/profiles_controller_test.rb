require "test_helper"

class Users::ProfilesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get users_profiles_index_url
    assert_response :success
  end
end
