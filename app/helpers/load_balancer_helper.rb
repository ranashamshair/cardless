module LoadBalancerHelper
  def load_bank_balancer(amount, card, customer, cvv, merchant)
    if merchant.payment_gateway.present?
      bank = merchant.payment_gateway
      if bank.stripe?
      end
    else
    end
  end
end
