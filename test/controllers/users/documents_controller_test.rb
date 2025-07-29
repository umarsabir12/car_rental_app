require "test_helper"

class Users::DocumentsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get users_documents_index_url
    assert_response :success
  end
end
