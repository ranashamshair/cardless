class AddIssueTransactionIdToTransactions < ActiveRecord::Migration[6.1]
  def change
    add_column :transactions, :issue_transaction_id, :integer
    add_column :transactions, :refund_transaction_id, :integer
  end
end
