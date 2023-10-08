require "test_helper"

class ReviewsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get reviews_index_url
    assert_response :success
  end

  test "should get question" do
    get reviews_question_url
    assert_response :success
  end

  test "should get result" do
    get reviews_result_url
    assert_response :success
  end
end
