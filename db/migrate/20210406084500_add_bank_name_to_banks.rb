# frozen_string_literal: true

class AddBankNameToBanks < ActiveRecord::Migration[6.1]
  def change
    add_column :banks, :bank_name, :string
  end
end
