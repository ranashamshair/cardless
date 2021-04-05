# frozen_string_literal: true

require 'test_helper'

class Merchant::AccountsControllerTest < ActionDispatch::IntegrationTest
  test 'should get show' do
    get merchant_accounts_show_url
    assert_response :success
  end
end
