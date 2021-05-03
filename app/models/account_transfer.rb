class AccountTransfer < ApplicationRecord
  belongs_to :receiver_wallet
  belongs_to :sender_wallet
  belongs_to :sender
  belongs_to :receiver
end
