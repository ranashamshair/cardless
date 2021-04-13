module Payment
  class StripeGateway
    include ApplicationHelper
    
    def tokenize_card(card, options = {})
      token = Stripe::Token.create(
        :card => {
            :number => card.number,
            :exp_month => card.expiry_date.month,
            :exp_year => card.expiry_date.year,
            :cvc => card.cvv,
            :customer => options[:customer]
        }
      )
      stripe_customer = Stripe::Customer.retrieve(customer) if options[:customer].present?
      stripe_customer.sources.create(source: token) if stripe_customer.present?
      raise StandardError.new('Stripe Card Tokenization Failed') if token.nil? || !token.card
      return {card_id: token.card.id, token: token.id}
    end

    def stripe_customer(user,user_stripe_id=nil,email)
      email = email || user.email
      begin
        customer = Stripe::Customer.retrieve(user_stripe_id, ENV["STRIPE_SECRET"]) if user_stripe_id.present?
        if customer.nil?
          customer = Stripe::Customer.create({:email => email}, {api_key: ENV["STRIPE_SECRET"]})
        end
        return customer
      rescue StandardError => e
        my_string = e.message.try(:downcase)
        customer = Stripe::Customer.create({:email => email}, {api_key: ENV["STRIPE_SECRET"]}) if my_string.include? "no such customer:"
        SlackService.notify("Stripe Customer retrieval failed : #{e.message.to_s}") if customer.blank?
        StandardError.new('Stripe Customer retrieval failed') if customer.blank?
      end
    end

    def stripe_charge(amount,card, key,user_id,customer_id,card_cvv,capture=nil)
      Stripe.api_key = key if key.present?
      capture = capture ? true : false
      begin
        card_info = Payment::DistroCard.new({fingerprint: card.fingerprint}, card.distro_token, user_id)
        customer = Stripe::Customer.retrieve(customer_id)
        card = create_card(customer, card_info, card_cvv)
        charge = Stripe::Charge.create({
                                           :amount => (dollars_to_cents(amount).to_i),
                                           :currency => "usd",
                                           :customer => customer_id,
                                           :card => card.id,
                                           :capture => capture
                                       })
      rescue Stripe::CardError, Stripe::InvalidRequestError => e
        body = e.json_body
        err  = body[:error]
        if err[:code].present?
          return {message: e.message, charge: nil,error_code: err[:decline_code].present? ? err[:decline_code].try(:humanize) : err[:code].try(:humanize)}
        else
          return {message: e.message, charge: nil,error_code: "unknown"}
        end
      end
      return {message: nil,charge: charge,error_code: nil}
    end

    private

    def create_card(customer, card_info, card_cvv)
      card = customer.sources.create(source: {
          :object => 'card',
          :number => card_info.number,
          :exp_month => card_info.month,
          :exp_year => card_info.year,
          :cvc => card_cvv
      })
      return card
    end
  end
end
