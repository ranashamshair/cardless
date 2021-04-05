# frozen_string_literal: true

require 'test_helper'

class Merchant::TransactionsControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get merchant_transactions_index_url
    assert_response :success
  end
end
