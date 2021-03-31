# frozen_string_literal: true

class CreateTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :transactions do |t|
      t.float :amount
      t.integer :status
      t.string :charge_id
      t.integer :sender_id
      t.integer :receiver_id
      t.integer :action
      t.float :fee
      t.float :reserve_money
      t.integer :main_type
      t.string :first6
      t.string :last4
      t.integer :sender_wallet_id
      t.integer :receiver_wallet_id
      t.float :sender_balance
      t.float :receiver_balance
      t.string :ref_id

      t.timestamps
    end
  end
end
