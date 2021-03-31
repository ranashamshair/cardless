# frozen_string_literal: true

class AddNewColumnsInFees < ActiveRecord::Migration[6.1]
  def change
    add_column :fees, :sale_credit_bank_percent, :float, default: 0
    add_column :fees, :sale_debit_bank_percent, :float, default: 0
    add_column :fees, :sale_credit_merchant_percent, :float, default: 0
    add_column :fees, :sale_debit_merchant_percent, :float, default: 0
    change_column :fees, :sale_credit_bank, :float, default: 0
    change_column :fees, :reserve, :float, default: 0
    change_column :fees, :sale_debit_bank, :float, default: 0
    change_column :fees, :sale_credit_merchant, :float, default: 0
    change_column :fees, :sale_debit_merchant, :float, default: 0
  end
end
