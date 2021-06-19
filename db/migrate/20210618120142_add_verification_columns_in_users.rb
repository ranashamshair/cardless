class AddVerificationColumnsInUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :tax_id, :string
    add_column :users, :nic, :string
    add_column :users, :business_license, :string
    add_column :users, :business_tax_id, :string
    add_column :users, :website, :string
  end
end
