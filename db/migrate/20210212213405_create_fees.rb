# frozen_string_literal: true

class CreateFees < ActiveRecord::Migration[6.1]
  def change
    create_table :fees do |t|
      t.float :sale, default: 0
      t.float :withdraw, default: 0
      t.float :reserve, default: 0
      t.integer :days, default: 0
      t.timestamps
    end
  end
end
