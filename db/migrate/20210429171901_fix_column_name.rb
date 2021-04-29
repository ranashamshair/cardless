class FixColumnName < ActiveRecord::Migration[6.1]
  def change
    rename_column :payment_gateways, :type, :gateway_type
  end
end
