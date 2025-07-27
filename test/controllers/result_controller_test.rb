require "test_helper"

class ResultControllerTest < ActionDispatch::IntegrationTest
  test "should get weather" do
    get result_weather_url
    assert_response :success
  end

  test "should get post" do
    get result_post_url
    assert_response :success
  end
end
