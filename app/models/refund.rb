class Refund < ApplicationRecord
  belongs_to :transfer_tx, class_name: "Transaction", foreign_key: :transfer_id
end
