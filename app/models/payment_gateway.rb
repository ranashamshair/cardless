# frozen_string_literal: true

class PaymentGateway < ApplicationRecord
  has_many :merchants
  enum type: { gocardless: 0, brain_tree_payments: 1, checkout: 2, dwolla: 3,  securion_pay: 4,
              _2_checkout: 5,  rapyd: 6,  stripe:7 }
end
