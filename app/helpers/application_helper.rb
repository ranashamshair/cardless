# frozen_string_literal: true

module ApplicationHelper
    include ActionView::Helpers::NumberHelper
    def dollars_to_cents(dollars)
        return number_with_precision(dollars.to_f * 100, precision: 2).to_i
    end

    def cents_to_dollars(cents)
        return number_with_precision(cents.to_f / 100, precision: 2)
    end

    def get_wallet_title(type)
      if type == "reserve"
        "Anti-Chargeback Reserved Funds"
      else
        "Available Funds"
      end
    end
end
