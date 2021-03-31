# frozen_string_literal: true

class CreateReserveSchedules < ActiveRecord::Migration[6.1]
  def change
    create_table :reserve_schedules do |t|
      t.integer :transaction_id
      t.datetime :release_date
      t.datetime :tx_date
      t.float :amount
      t.string :tx_id
      t.string :reserve_status
      t.integer :user_id
      t.integer :reserve_tx_id
      t.timestamps
    end
  end
end
