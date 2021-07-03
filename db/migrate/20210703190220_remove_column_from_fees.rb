class RemoveColumnFromFees < ActiveRecord::Migration[6.1]
  def change
    remove_column :fees, :reward_percent
  end
end
