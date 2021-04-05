# frozen_string_literal: true

class PaymentGateway < ApplicationRecord
  has_many :merchants
end
