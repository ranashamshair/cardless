# frozen_string_literal: true

class Withdraw < ApplicationRecord
  belongs_to :user
  belongs_to :withdraw_transaction, class_name: 'Transaction', foreign_key: :transaction_id, optional: true
end
