module Payment
  class BrainTree

    def initialize(merchant_id, public_key, secret_key)
      @gateway = Braintree::Gateway.new(
        :environment => :sandbox,
        :merchant_id => merchant_id,
        :public_key => public_key,
        :private_key => secret_key,
      )
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
      result = @gateway.transaction.sale(
        :amount => amount,
        credit_card: {
          cardholder_name: card_name,
          cvv: cvv,
          number: number,
          expiration_date: expiration_date
        },
        :options => {
          :submit_for_settlement => true
        }
      )

      if result.success?
        return {message: nil, charge: result.transaction.id, error: nil}
      else
        return {message: result.errors.first.message, charge: nil, error: result.errors.first.code}
      end
    end

    def refund(id)
      result = @gateway.transaction.refund(id)
      if result.success?
        return {message: nil, charge: result.transaction.id, error: nil}
      else
        return {message: result.errors.first.message, charge: nil, error: result.errors.first.code}
      end
    end

  end
end
