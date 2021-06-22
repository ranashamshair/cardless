class TransactionMailer < ApplicationMailer

  def customer_email(customer, merchant, transaction)
    @customer = customer
    @merchant  = merchant
    @transaction = transaction
    mail(to: @customer.email, subject: "Invoice for payment at #{@merchant.company}")
  end

  def merchant_email(customer, merchant, transaction)
    @customer = customer
    @merchant  = merchant
    @transaction = transaction
    mail(to: @merchant.email, subject: "Invoice for payment from #{@customer.email}")
  end
end
