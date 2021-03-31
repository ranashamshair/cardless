# frozen_string_literal: true

class AddOrgColumnsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :org_name, :string
    add_column :users, :business_type, :string
  end
end
