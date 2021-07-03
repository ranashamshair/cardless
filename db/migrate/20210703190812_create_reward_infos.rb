class CreateRewardInfos < ActiveRecord::Migration[6.1]
  def change
    create_table :reward_infos do |t|
      t.float :amount

      t.timestamps
    end
  end
end
