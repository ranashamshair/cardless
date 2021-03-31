# frozen_string_literal: true

require 'test_helper'

class Admin::FeesControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get admin_fees_index_url
    assert_response :success
  end
end
