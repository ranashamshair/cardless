# frozen_string_literal: true

class AddBankToTransactions < ActiveRecord::Migration[6.1]
  def change
    add_reference :transactions, :bank, null: false, foreign_key: true
  end
end
