# frozen_string_literal: true

class ChangeIsActiveInUsers < ActiveRecord::Migration[6.1]
  def change
    change_column :users, :is_active, :string
  end
end
