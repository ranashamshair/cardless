# frozen_string_literal: true

class AddBankToWithdraws < ActiveRecord::Migration[6.1]
  def change
    add_reference :withdraws, :bank, null: false, foreign_key: true
  end
end
