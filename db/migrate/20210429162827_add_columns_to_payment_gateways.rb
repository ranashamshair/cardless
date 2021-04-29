class AddColumnsToPaymentGateways < ActiveRecord::Migration[6.1]
  def change
    add_column :payment_gateways, :merchant_id, :string
    add_column :payment_gateways, :redirect_url, :string
    add_column :payment_gateways, :base_url, :string
    add_column :payment_gateways, :secret_word, :string
  end
end
