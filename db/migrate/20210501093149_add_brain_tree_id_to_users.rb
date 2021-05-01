class AddBrainTreeIdToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :brain_tree_id, :string
  end
end
