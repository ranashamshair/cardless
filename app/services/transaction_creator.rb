include Payment
class TransactionCreator

  attr_accessor :merchant, :customer, :card, :amount, :cvv

  def initialize(merchant,customer,card,amount,cvv)
    @merchant = merchant
    @customer = customer
    @card = card
    @amount = amount
    @cvv = cvv
  end

  def charge_on_gateway
    trans_payment_gateway = if merchant.payment_gateway.present?
                              merchant.payment_gateway
                            else
                              PaymentGateway.red_sys.first
                            end

    card_info = Payment::DistroCard.new({ fingerprint: card.fingerprint }, card.distro_token, customer.id)

    charge_gateway = Payment::Gateway.new(trans_payment_gateway)

    charge_gateway.charge({
                            amount: amount, #24.44$
                            cvv: cvv, # 231
                            card_name: customer.name, # John Sins
                            card_number: card_info.number, # 4242424242424242
                            expiry_date: "#{card_info.month}#{card_info.year.last(2)}", # 0728
                            email: customer.email, # abc@gmail.com
                            customer: customer,
                            exp_month:  card_info.month,
                            exp_year: card_info.year
                          })

  end
end
