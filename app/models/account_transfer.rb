class AccountTransfer < ApplicationRecord
  belongs_to :receiver_wallet, class_name: 'Wallet', foreign_key: :receiver_wallet_id, optional: true
  belongs_to :sender_wallet, class_name: 'Wallet', foreign_key: :sender_wallet_id, optional: true
  belongs_to :sender, class_name: 'User', foreign_key: :sender_id, optional: true
  belongs_to :receiver, class_name: 'User', foreign_key: :receiver_id, optional: true
end
