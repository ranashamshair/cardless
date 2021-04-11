class ChangeColumnNullTrueTransection < ActiveRecord::Migration[6.1]
  def change
    change_column_null :transactions, :bank_id, true
  end
end
