# frozen_string_literal: true

require 'test_helper'

class Admin::MerchantsControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get admin_merchants_index_url
    assert_response :success
  end
end
