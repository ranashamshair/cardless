class AddRefIdToAccountTransfer < ActiveRecord::Migration[6.1]
  def change
    add_column :account_transfers, :ref_id, :string
  end
end
