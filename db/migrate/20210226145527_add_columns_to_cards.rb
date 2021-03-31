# frozen_string_literal: true

class AddColumnsToCards < ActiveRecord::Migration[6.1]
  def change
    add_column :cards, :brand, :string
    add_column :cards, :card_type, :string
  end
end
