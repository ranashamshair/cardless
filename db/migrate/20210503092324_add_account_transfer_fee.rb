class AddAccountTransferFee < ActiveRecord::Migration[6.1]
  def change
    add_column :fees, :account_transfer, :float, default: 0
  end
end
