require "test_helper"

class Merchant::RewardsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get merchant_rewards_index_url
    assert_response :success
  end
end
