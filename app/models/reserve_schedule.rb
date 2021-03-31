# frozen_string_literal: true

class ReserveSchedule < ApplicationRecord
  enum reserve_status: { 'pending' => 'pending', 'transfered' => 'transfered' }

  belongs_to :user
  belongs_to :main_tx, class_name: 'Transaction', foreign_key: :transaction_id
  belongs_to :reserve_tx, class_name: 'Transaction', foreign_key: :reserve_tx_id
end
