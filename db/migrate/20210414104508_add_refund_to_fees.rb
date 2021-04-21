class AddRefundToFees < ActiveRecord::Migration[6.1]
  def change
    add_column :fees, :refund, :float, default: 0
  end
end
