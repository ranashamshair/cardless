class AddPaymentGatewayIdToUsers < ActiveRecord::Migration[6.1]
  def change
    add_reference :users, :payment_gateway_id, index: true
  end
end
