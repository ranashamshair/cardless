class AddTxRefToAccountTransfer < ActiveRecord::Migration[6.1]
  def change
    add_column :account_transfers, :tx_id, :integer
  end
end
