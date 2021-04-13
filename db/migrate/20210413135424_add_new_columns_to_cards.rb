class AddNewColumnsToCards < ActiveRecord::Migration[6.1]
  def change
    add_column :cards, :fingerprint, :text
    add_column :cards, :distro_token, :text
  end
end
