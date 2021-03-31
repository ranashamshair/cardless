# frozen_string_literal: true

class AddCardIdToTransaction < ActiveRecord::Migration[6.1]
  def change
    add_column :transactions, :card_id, :integer
  end
end
