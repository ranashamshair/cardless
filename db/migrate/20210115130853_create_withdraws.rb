# frozen_string_literal: true

class CreateWithdraws < ActiveRecord::Migration[6.1]
  def change
    create_table :withdraws do |t|
      t.string :name
      t.references :user, null: false, foreign_key: true
      t.boolean :is_payed
      t.float :amount, default: 0

      t.timestamps
    end
  end
end
