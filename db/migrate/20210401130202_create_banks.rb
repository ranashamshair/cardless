# frozen_string_literal: true

class CreateBanks < ActiveRecord::Migration[6.1]
  def change
    create_table :banks do |t|
      t.references :user, null: false, foreign_key: true
      t.string :iban
      t.integer :status
      t.string :currency
      t.string :user_name

      t.timestamps
    end
  end
end
