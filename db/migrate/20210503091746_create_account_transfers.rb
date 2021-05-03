class CreateAccountTransfers < ActiveRecord::Migration[6.1]
  def change
    create_table :account_transfers do |t|
      t.integer :receiver_wallet_id
      t.integer :sender_wallet_id
      t.float :amount
      t.text :instruction
      t.string :reason
      t.float :sender_balance
      t.float :receiver_balance
      t.integer :sender_id
      t.integer :receiver_id

      t.timestamps
    end
  end
end
