class AddCountryToBanks < ActiveRecord::Migration[6.1]
  def change
    add_column :banks, :country, :string
  end
end
