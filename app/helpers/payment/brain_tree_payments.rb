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
          number: arg[:card_number],
          expiration_date: "#{expiry_month(arg[:expiry_date])}/#{expiry_year(arg[:expiry_date])}"
        },
        options: {
          submit_for_settlement: true
        }
      )
    end

    def handle_charge_response(result)
      if result.success?
        { message: nil, charge: result.transaction.id, error_code: nil, response: result.transaction.to_json }
      else
        { message: result.errors.first.message, charge: nil, error_code: result.errors.first.code,
          response: result.errors }
      end
    end

    def handle_refund_response(result)
      if result.success?
        { message: nil, refund: result.transaction.id, refunded_amount: result.transaction.amount.to_f, error_code: nil, response: result.transaction.to_json }
      else
        { message: result.errors.first.message, refund: nil, error_code: result.errors.first.code,
          response: result.errors }
      end
    end

    def refund(args)
      trans = find_transaction(args[:charge_id])
      @result = if %w[authorized submitted_for_settlement settlement_pending].include?(trans.status)
                  call_void(args)
                elsif ['voided'].include?(trans.status)
                  raise StandardError, 'already refunded'
                else
                  call_refund(args)
                end

    end

    private

    def merchant_id
      payment_gateway.merchant_id
    end

    def public_key
      payment_gateway.client_id
    end

    def private_key
      payment_gateway.client_secret
    end

    def call_refund(args)
      @brain_tree.transaction.refund(args[:charge_id], args[:amount])
    end

    def call_void(args)
      @brain_tree.transaction.void(args[:charge_id])
    end

    def find_transaction(charge_id)
      @brain_tree.transaction.find(charge_id)
    end

  end
end
