# frozen_string_literal: true

class AddColumnsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :country, :string
    add_column :users, :city, :string
    add_column :users, :state, :string
    add_column :users, :phone_number, :string
    add_column :users, :company, :string
    add_column :users, :role, :string
    add_column :users, :is_active, :boolean, default: false
  end
end
