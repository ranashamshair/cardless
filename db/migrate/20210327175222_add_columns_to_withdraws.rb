# frozen_string_literal: true

class AddColumnsToWithdraws < ActiveRecord::Migration[6.1]
  def change
    add_column :withdraws, :ref_id, :string
    add_column :withdraws, :transaction_id, :integer
  end
end
