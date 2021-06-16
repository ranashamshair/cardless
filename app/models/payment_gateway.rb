# frozen_string_literal: true

class PaymentGateway < ApplicationRecord
  has_many :merchants
  enum gateway_type: {
    go_cardless: 0,
    brain_tree_payments: 1,
    checkout: 2,
    dwolla: 3,
    securion_pay: 4,
    two_checkout: 5,
    rapyd: 6,
    stripe: 7,
    authorize_pay: 8,
    blue_snap: 9,
    cardinity: 10,
    smart_pay: 11
  }
end
