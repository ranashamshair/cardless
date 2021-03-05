class Wallet < ApplicationRecord
    belongs_to :user
    enum wallet_type: {"primary" => "primary", "reserve" => "reserve"}

    extend FriendlyId
    friendly_id :name, use: :slugged
end
