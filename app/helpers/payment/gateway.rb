# frozen_string_literal: true

module Payment
  # this is comment
  class Gateway

    class_attribute :payment_gateway
    attr_accessor :gateway

    def initialize(payment_gateway)
      Gateway.payment_gateway = payment_gateway
      @gateway = "Payment::#{gateway_class}".constantize.new
    end

    def charge(arg)
      # arg = {
      #   amount: '',
      #   cvv: '',
      #   card_name: '',
      #   card_number: '',
      #   expiry_date: ''
      # }
      response = gateway.charge(arg)
      gateway.handle_charge_response(response)
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
  end
end
