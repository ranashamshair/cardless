# frozen_string_literal: true

class AddPaymentGatewayIdToUsers < ActiveRecord::Migration[6.1]
  def change
    add_reference :users, :payment_gateway, index: true
  end
end
