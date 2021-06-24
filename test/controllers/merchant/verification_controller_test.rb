require "test_helper"

class Merchant::VerificationControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get merchant_verification_index_url
    assert_response :success
  end
end
