# frozen_string_literal: true

module Admin::PaymentGatewaysHelper
    def default_gateway_type(type)
      case type
        when 'gocardless'
          return 0
        when 'brain_tree_payments'
          return 1
        when 'checkout'
          return 2
        when 'dwolla'
          return 3
        when 'securion_pay'
          return 4
        when '_2_checkout'
          return 5
        when 'rapyd'
          return 6
        when 'stripe'
          return 7
      end

    end
end
