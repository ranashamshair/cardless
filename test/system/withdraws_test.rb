# frozen_string_literal: true

require 'application_system_test_case'

class WithdrawsTest < ApplicationSystemTestCase
  setup do
    @withdraw = withdraws(:one)
  end

  test 'visiting the index' do
    visit withdraws_url
    assert_selector 'h1', text: 'Withdraws'
  end

  test 'creating a Withdraw' do
    visit withdraws_url
    click_on 'New Withdraw'

    fill_in 'Amount', with: @withdraw.amount
    check 'Is payed' if @withdraw.is_payed
    fill_in 'Name', with: @withdraw.name
    fill_in 'User', with: @withdraw.user_id
    click_on 'Create Withdraw'

    assert_text 'Withdraw was successfully created'
    click_on 'Back'
  end

  test 'updating a Withdraw' do
    visit withdraws_url
    click_on 'Edit', match: :first

    fill_in 'Amount', with: @withdraw.amount
    check 'Is payed' if @withdraw.is_payed
    fill_in 'Name', with: @withdraw.name
    fill_in 'User', with: @withdraw.user_id
    click_on 'Update Withdraw'

    assert_text 'Withdraw was successfully updated'
    click_on 'Back'
  end

  test 'destroying a Withdraw' do
    visit withdraws_url
    page.accept_confirm do
      click_on 'Destroy', match: :first
    end

    assert_text 'Withdraw was successfully destroyed'
  end
end
