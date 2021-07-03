class AddPaymentGatewayIdToTransactions < ActiveRecord::Migration[6.1]
  def change
    add_column :transactions, :payment_gateway_id, :integer
  end
end
