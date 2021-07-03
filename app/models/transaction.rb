# frozen_string_literal: true

class Transaction < ApplicationRecord
  enum action: { transfer: 0, issue: 1, retire: 2 }
  enum status: { pending: 0, success: 1, refunded: 2 }
  enum main_type: { virtual_terminal: 0, withdraw: 1, customer_issue: 2, reserve: 3, reserve_return: 4,
                    virtual_terminal_fee: 5, withdraw_fee: 6, account_transfer: 7, account_transfer_fee: 8,
                    reward: 9, refund: 10, refund_fee: 11 }
  REASON = ['Duplicate', 'Fraudulent', 'Requested By Customer'].freeze
  belongs_to :sender, class_name: 'User', foreign_key: :sender_id, optional: true
  belongs_to :receiver, class_name: 'User', foreign_key: :receiver_id, optional: true
  belongs_to :sender_wallet, class_name: 'Wallet', foreign_key: :sender_wallet_id, optional: true
  belongs_to :receiver_wallet, class_name: 'Wallet', foreign_key: :receiver_wallet_id, optional: true
  belongs_to :bank, optional: true
  belongs_to :card, optional: true
  belongs_to :payment_gateway, optional: true
  belongs_to :issue_transaction,
             class_name: 'Transaction', optional: true
  belongs_to :refund_transaction,
             class_name: 'Transaction', optional: true
  has_many :refunds, class_name: "Refund", foreign_key: :transfer_id
end
