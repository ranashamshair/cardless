# frozen_string_literal: true

class AddColumnsInFees < ActiveRecord::Migration[6.1]
  def change
    rename_column :fees, :sale, :sale_credit_bank
    change_column :fees, :sale_credit_bank, :integer, default: 0
    change_column :fees, :reserve, :integer, default: 0
    add_column :fees, :sale_debit_bank, :integer, default: 0
    add_column :fees, :sale_credit_merchant, :integer, default: 0
    add_column :fees, :sale_debit_merchant, :integer, default: 0
  end
end
