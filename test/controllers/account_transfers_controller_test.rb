require "test_helper"

class AccountTransfersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get account_transfers_index_url
    assert_response :success
  end
end
