# frozen_string_literal: true

class CreateWallets < ActiveRecord::Migration[6.1]
  def change
    create_table :wallets do |t|
      t.string :name
      t.string :wallet_type
      t.references :user, null: false, foreign_key: true
      t.float :balance, default: 0
      t.timestamps
    end
  end
end
