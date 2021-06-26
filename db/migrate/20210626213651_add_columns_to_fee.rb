class AddColumnsToFee < ActiveRecord::Migration[6.1]
  def change
    add_column :fees, :reward_amount, :float, default: 0
    add_column :fees, :reward_percent, :float, default: 0
  end
end
