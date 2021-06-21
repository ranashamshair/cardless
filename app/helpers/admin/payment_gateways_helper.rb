# frozen_string_literal: true

module Admin::PaymentGatewaysHelper
    def default_gateway_type(type)
      case type
        when 'brain_tree_payments'
          return 0
        when 'authorize_pay'
          return 1
        when 'blue_snap'
          return 2
        when 'securion_pay'
          return 3
        when 'cardinity'
          return 4
        when 'smart_pay'
          return 5
        when 'stripe'
          return 6
        when 'red_sys'
          return 7
      end

    end
end
