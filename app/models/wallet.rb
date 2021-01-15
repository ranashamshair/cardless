class Wallet < ApplicationRecord
    belongs_to :user
    enum wallet_type: {"primary" => "primary", "reserve" => "reserve"}
end
