class AddFeeToAccountTransfers < ActiveRecord::Migration[6.1]
  def change
    add_column :account_transfers, :fee, :float, default: 0
  end
end
