# frozen_string_literal: true

require 'test_helper'

class Merchant::DashboardControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get merchant_dashboard_index_url
    assert_response :success
  end
end
