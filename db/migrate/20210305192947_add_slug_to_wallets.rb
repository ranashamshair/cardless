# frozen_string_literal: true

class AddSlugToWallets < ActiveRecord::Migration[6.1]
  def change
    add_column :wallets, :slug, :string
    add_index :wallets, :slug, unique: true
  end
end
