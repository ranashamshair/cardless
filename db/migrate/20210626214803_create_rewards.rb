class CreateRewards < ActiveRecord::Migration[6.1]
  def change
    create_table :rewards do |t|
      t.integer :user_id
      t.float :amount, default: 0
      t.boolean :payed, default: false
      t.datetime :payed_at
      t.timestamps
    end
  end
end
