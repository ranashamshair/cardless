# frozen_string_literal: true

class PaymentGateway < ApplicationRecord
  has_many :merchants
  enum gateway_type: { brain_tree_payments: 0, authorize_pay: 1, blue_snap: 2,  securion_pay: 3,
              cardinity: 4,  smart_pay: 5,  stripe: 6 }
end
