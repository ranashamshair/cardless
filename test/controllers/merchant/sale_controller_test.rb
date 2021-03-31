# frozen_string_literal: true

require 'test_helper'

class Merchant::SaleControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get merchant_sale_index_url
    assert_response :success
  end
end
