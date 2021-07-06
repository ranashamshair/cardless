require "test_helper"

class Admin::RewardInfoControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_reward_info_index_url
    assert_response :success
  end

  test "should get new" do
    get admin_reward_info_new_url
    assert_response :success
  end

  test "should get edit" do
    get admin_reward_info_edit_url
    assert_response :success
  end

  test "should get create" do
    get admin_reward_info_create_url
    assert_response :success
  end

  test "should get update" do
    get admin_reward_info_update_url
    assert_response :success
  end
end
