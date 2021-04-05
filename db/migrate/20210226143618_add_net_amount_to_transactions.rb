# frozen_string_literal: true

class AddNetAmountToTransactions < ActiveRecord::Migration[6.1]
  def change
    add_column :transactions, :net_amount, :float, default: 0
  end
end
