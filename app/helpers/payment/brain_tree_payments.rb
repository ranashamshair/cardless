module Payment
  class BrainTreePayments < Gateway

    def initialize
      @brain_tree = if payment_gateway.present?
                      Braintree::Gateway.new(
                        environment: sandbox,
                        merchant_id: merchant_id,
                        public_key: public_key,
                        private_key: private_key
                      )
                    end
    end

    def create_customer
      #TODO not in use currently
      result = @gateway.customer.create(
        first_name: "Jen",
        last_name: "Smith",
        company: "Braintree",
        email: "jen@example.com",
        phone: "312.555.1234",
        fax: "614.555.5678",
        website: "www.example.com"
      )
      if result.success?
        puts result.customer.id
      else
        p result.errors
      end
    end

    def charge(arg)
      @brain_tree.transaction.sale(
        amount: arg[:amount],
        credit_card: {
          cardholder_name: arg[:card_name], cvv: arg[:cvv],
          number: arg[:card_number], expiration_date: arg[:expiry_date]
        },
        options: {
          submit_for_settlement: true
        }
      )
    end

    def handle_charge_response(response)
      handle_response(response)
    end

    def refund(id)
      trans = find_transaction(id)
      @result = if %w[authorized submitted_for_settlement settlement_pending].include?(trans.status)
                  call_void(id)
                else
                  call_refund(id)
                end

      if result.success?
        return { message: nil, charge: result.transaction.id, error: nil, response: result.transaction}
      else
        return { message: result.errors.first.message, charge: nil, error: result.errors.first.code, response: result.errors}
      end
    end

    private

    def handle_response(result)
      if result.success?
        return { message: nil, charge: result.transaction.id, error: nil, response: result.transaction }
      else
        return { message: result.errors.first.message, charge: nil, error: result.errors.first.code,
                 response: result.errors }
      end
    end

    def merchant_id
      payment_gateway.merchant_id
    end

    def public_key
      payment_gateway.client_id
    end

    def private_key
      payment_gateway.client_secret
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
