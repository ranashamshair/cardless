# frozen_string_literal: true

module Payment
  # this is comment
  class Gateway

    cattr_accessor :payment_gateway
    attr_accessor :gateway

    def initialize(payment_gateway)
      Gateway.payment_gateway = payment_gateway
      @gateway = "Payment::#{gateway_class}".constantize.new
    end

    def charge(arg)
      # arg = {
      #   amount: '', 24.44$
      #   cvv: '', 231
      #   card_name: '', John Sins
      #   card_number: '', 4242424242424242
      #   expiry_date: '' 0728
      #   email: '' abc@gmail.com
      #   customer: User.last
      # }
      begin
        response = gateway.charge(arg)
        gateway.handle_charge_response(response)
      rescue Exception => e
        return { message: e.message, charge: nil, error_code: "unknown #{payment_gateway.id} #{payment_gateway.gateway_type}", response: e }
      end
    end

    def refund(arg)
      # arg = {
      #   amount: '', 24.44$
      #   charge_id: ''
      # }
      begin
        response = gateway.refund(arg)
        gateway.handle_refund_response(response)
      rescue Exception => e
        return { message: e.message, refund: nil, error_code: "unknown #{payment_gateway.id} #{payment_gateway.gateway_type}", response: e }
      end
    end

    def sandbox
      'sandbox'.to_sym
    end

    def first_name(full_name)
      full_name.split(' ').first
    end

    def last_name(full_name)
      full_name.split(' ').last
    end

    def expiry_month(exp_date)
      exp_date.first(2)
    end

    def expiry_year(exp_date)
      exp_date.last(2)
    end

    def complete_exp_year(exp_date)
      "20#{expiry_year(exp_date)}"
    end

    def gateway_class
      payment_gateway.gateway_type.split('_').map(&:titleize).join
    end

    def currency
      'EUR'
    end

    def dollar_to_cents(dollar_amount)
      dollar_amount * 100
    end
  end
end
