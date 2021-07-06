class AddChargeIdToRefund < ActiveRecord::Migration[6.1]
  def change
    add_column :refunds, :charge_id, :string
  end
end
