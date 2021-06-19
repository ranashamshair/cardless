module Payment
  class StripeGateway < Gateway

    def initialize
      Stripe.api_key = gateway_api
    end

    def charge(args)
      customer = args[:customer]
      stripe_customer = stripe_customer(customer,customer.stripe_customer_id,customer.email)
      stripe_charge = stripe_charge(
        args,
        stripe_customer.id
      )
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
      stripe_customer = Stripe::Customer.retrieve(stripe_customer_id)
      stripe_customer.sources.create(source: token) if stripe_customer.present?
      raise StandardError, 'Stripe Card Tokenization Failed' if token.nil? || !token.card

      { id: token.card.id, token: token.id }
    end

    def stripe_customer(user,user_stripe_id=nil,email)
      email = email || user.email
      begin
        customer = Stripe::Customer.retrieve(user_stripe_id, ENV["STRIPE_SECRET"]) if user_stripe_id.present?
        if customer.nil?
          customer = Stripe::Customer.create({ email: email }, { api_key: ENV["STRIPE_SECRET"] })
          user.update(stripe_customer_id: customer.id)
        end
        return customer
      rescue StandardError => e
        my_string = e.message.try(:downcase)
        customer = Stripe::Customer.create({ email: email }, { api_key: ENV["STRIPE_SECRET"] }) if my_string.include? "no such customer:"
        # SlackService.notify("Stripe Customer retrieval failed : #{e.message.to_s}") if customer.blank?
        raise StandardError, 'Stripe Customer retrieval failed' if customer.blank?
      end
    end

    # def stripe_charge(amount,customer_id,card_cvv)
    def stripe_charge(args,stripe_customer_id)
      begin
        card = tokenize_card(stripe_customer_id, args)
        charge = Stripe::Charge.create({
                                         amount: (dollars_to_cents(args[:amount]).to_i),
                                         currency: currency,
                                         customer: stripe_customer_id,
                                         card: card[:id],
                                         capture: true
                                       })
      rescue Stripe::CardError, Stripe::InvalidRequestError => e
        body = e.json_body
        err  = body[:error]
        if err[:code].present?
          return { message: e.message, charge: nil,error_code: err[:decline_code].present? ? err[:decline_code].try(:humanize) : err[:code].try(:humanize) }
        else
          return { message: e.message, charge: nil,error_code: "unknown" }
        end
      end
      return { message: nil,charge: charge,error_code: nil }
    end

    def refund(id, key)
      Stripe.api_key = key if key.present?
      refund = Stripe::Refund.create({
                                       charge: id,
                                     })
      if refund['status'] == 'succeeded'
        return { message: nil, charge: refund.id }
      else
        return { message: refund, charge: nil }
      end
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
      payment_gateway.client_secret
    end
  end
end
