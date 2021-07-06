module Payment
  class StripeGateway < Gateway

    def initialize
      Stripe.api_key = gateway_api
    end

    def charge(args)
      customer = args[:customer]
      stripe_customer = stripe_customer(customer,customer.stripe_customer_id,customer.email)
      stripe_charge(args, stripe_customer.id)
    end

    def tokenize_card(stripe_customer_id, args)
      token = Stripe::Token.create(
        card: {
          number: args[:card_number],
          exp_month: expiry_month(args[:expiry_date]),
          exp_year: complete_exp_year(args[:expiry_date]),
          cvc: args[:cvv],
          customer: stripe_customer_id
        }
      )
      Stripe::Customer.create_source(stripe_customer_id,
                                     {source: token.id }
      )
      # stripe_customer = Stripe::Customer.retrieve(stripe_customer_id)
      # stripe_customer.sources.create(source: token) if stripe_customer.present?

      raise StandardError, 'Stripe Card Tokenization Failed' if token.nil? || !token.card

      token.card.id
    end

    def stripe_customer(user,user_stripe_id=nil,email)
      email = email || user.email
      begin
        customer = Stripe::Customer.retrieve(user_stripe_id, gateway_api) if user_stripe_id.present?
        if customer.nil?
          customer = Stripe::Customer.create({ email: email }, { api_key: gateway_api })
          user.update(stripe_customer_id: customer.id)
        end
        return customer
      rescue StandardError => e
        my_string = e.message.try(:downcase)
        customer = Stripe::Customer.create({ email: email }, { api_key: gateway_api }) if my_string.include? "no such customer:"
        # SlackService.notify("Stripe Customer retrieval failed : #{e.message.to_s}") if customer.blank?
        raise StandardError, 'Stripe Customer retrieval failed' if customer.blank?
      end
    end

    # def stripe_charge(amount,customer_id,card_cvv)
    def stripe_charge(args,stripe_customer_id)
      begin
        card_token = tokenize_card(stripe_customer_id, args)
        charge = Stripe::Charge.create({
                                         amount: dollar_to_cents(args[:amount].to_i),
                                         currency: currency,
                                         customer: stripe_customer_id,
                                         card: card_token,
                                         capture: true
                                       })
      rescue Stripe::CardError, Stripe::InvalidRequestError => e
        body = e.json_body
        err  = body[:error]
        if err[:code].present?
          return { message: e.message, charge: nil, error_code: err[:decline_code].present? ? err[:decline_code].try(:humanize) : err[:code].try(:humanize), response: err }
        else
          return { message: e.message, charge: nil, error_code: "unknown", response: err }
        end

      end
      return { message: nil,charge: charge.id, error_code: nil, response: charge.to_json }
    end

    def handle_charge_response(response)
      response
    end

    def refund(args)
      refund = Stripe::Refund.create({
                                       charge: args[:charge_id],
                                       amount: args[:amount]
                                     })
      if refund['status'] == 'succeeded'
        return { message: nil, refund: refund.id, refunded_amount: refund.amount, error_code: nil, response: refund.to_json }
      else
        return { message: refund, refund: nil, error_code: refund, response: refund.to_json }
      end
    end

    def handle_refund_response(response)
      response
    end

    private

    def create_card(customer, card_info, card_cvv)
      card = customer.sources.create(source: {
                                       object: 'card',
                                       number: card_info.number,
                                       exp_month: card_info.month,
                                       exp_year: card_info.year,
                                       cvc: card_cvv
                                     })
      return card
    end

    def gateway_api
      # ENV["STRIPE_SECRET"]
      'sk_test_51J47MyHW0K48LBP7ZHZqH4CKDVLRQvnnhPTHtzO3EMTe2AeT1cfm9MkHqg1EogjR05v34x97XbpaSTrWmKD3Hwd4002kXhVzBD'
      # payment_gateway.client_secret
    end
  end
end
