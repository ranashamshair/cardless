class CreateRefunds < ActiveRecord::Migration[6.1]
  def change
    create_table :refunds do |t|
      t.float :amount
      t.string :reason
      t.integer :transfer_id
      t.integer :sender_id
      t.integer :receiver_id
      t.integer :refund_tx_id

      t.timestamps
    end
  end
end
