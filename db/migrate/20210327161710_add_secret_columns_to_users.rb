# frozen_string_literal: true

class AddSecretColumnsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :authentication_token, :string
    add_column :users, :secret_key, :string
    add_column :users, :public_key, :string
  end
end
