# frozen_string_literal: true

class CreateCards < ActiveRecord::Migration[6.1]
  def change
    create_table :cards do |t|
      t.string :first6
      t.string :last4
      t.string :exp_date
      t.integer :user_id
      t.timestamps
    end
  end
end
