module Payment
  class BrainTree

    attr_accessor :gateway, :result

    def initialize(payment_gateway)
      if payment_gateway.present?
        @gateway = Braintree::Gateway.new(
          :environment => :sandbox,
          :merchant_id => payment_gateway.merchant_id,
          :public_key => payment_gateway.client_id,
          :private_key => payment_gateway.client_secret,
          )
      end
    end

    def create_customer
      #TODO not in use currently
      result = @gateway.customer.create(
        :first_name => "Jen",
        :last_name => "Smith",
        :company => "Braintree",
        :email => "jen@example.com",
        :phone => "312.555.1234",
        :fax => "614.555.5678",
        :website => "www.example.com"
      )
      if result.success?
        puts result.customer.id
      else
        p result.errors
      end
    end

    def charge(amount, card_name, card_number, cvv, expiration_date)
      @result = @gateway.transaction.sale(
        :amount => amount,
        credit_card: {
          cardholder_name: card_name,
          cvv: cvv,
          number: card_number,
          expiration_date: expiration_date
        },
        :options => {
          :submit_for_settlement => true
        }
      )

      if result.success?
        return {message: nil, charge: result.transaction.id, error: nil, response: result.transaction}
      else
        return {message: result.errors.first.message, charge: nil, error: result.errors.first.code, response: result.errors}
      end
    end

    def refund(id)
      trans = find_transaction(id)
      @result = if %w[authorized submitted_for_settlement settlement_pending].include?(trans.status)
                  call_void(id)
                else
                  call_refund(id)
                end

      if result.success?
        return {message: nil, charge: result.transaction.id, error: nil, response: result.transaction}
      else
        return {message: result.errors.first.message, charge: nil, error: result.errors.first.code, response: result.errors}
      end
    end

    def call_refund(charge_id)
      @gateway.transaction.refund(charge_id)
    end

    def call_void(charge_id)
      @gateway.transaction.void(charge_id)
    end

    def find_transaction(charge_id)
      @gateway.transaction.find(charge_id)
    end

  end
end
