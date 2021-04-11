# frozen_string_literal: true

class AddNewColumnsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :street_address, :string
    add_column :users, :zip_code, :string
  end
end
