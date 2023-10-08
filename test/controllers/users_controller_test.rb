require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get my_page" do
    get users_my_page_url
    assert_response :success
  end

  test "should get edit" do
    get users_edit_url
    assert_response :success
  end

  test "should get confirm" do
    get users_confirm_url
    assert_response :success
  end

  test "should get withdrawal" do
    get users_withdrawal_url
    assert_response :success
  end
end
