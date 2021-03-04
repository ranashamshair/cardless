class ReserveSchedule < ApplicationRecord

    enum reserve_status: {"pending" => "pending",  "transfered" => "transfered"}

    belongs_to :user
    belongs_to :main_tx, class_name: "Transaction", foreign_key: :transaction_id
end
