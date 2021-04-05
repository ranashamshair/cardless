# frozen_string_literal: true

class AddTotalFeeToTransactions < ActiveRecord::Migration[6.1]
  def change
    add_column :transactions, :total_fee, :float, default: 0
  end
end
