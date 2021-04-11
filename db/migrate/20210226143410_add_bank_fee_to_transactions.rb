# frozen_string_literal: true

class AddBankFeeToTransactions < ActiveRecord::Migration[6.1]
  def change
    add_column :transactions, :bank_fee, :float, default: 0
  end
end
