include Payment
class TransactionRefund
  attr_accessor :charge_id, :merchant, :amount, :trans_payment_gateway

  def initialize(transaction, merchant, amount = nil)
    @charge_id = transaction.charge_id
    @amount = amount
    @merchant = merchant
    @trans_payment_gateway = transaction.payment_gateway
  end

  def refund_on_gateway
    refund_gateway = Payment::Gateway.new(trans_payment_gateway)
    response = refund_gateway.refund({
                                       charge_id: charge_id,
                                       amount: amount
                                     })
  end
end
