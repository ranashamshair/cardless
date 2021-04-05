# frozen_string_literal: true

require 'test_helper'

class Merchant::ReserveSchedulesControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get merchant_reserve_schedules_index_url
    assert_response :success
  end
end
