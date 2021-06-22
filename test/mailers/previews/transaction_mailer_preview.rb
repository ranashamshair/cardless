# Preview all emails at http://localhost:3000/rails/mailers/transaction_mailer
class TransactionMailerPreview < ActionMailer::Preview

  def customer_email
    TransactionMailer.customer_email(User.find(4), User.find(2), Transaction.find(14))
  end

  def merchant_email
    TransactionMailer.merchant_email(User.find(4), User.find(2), Transaction.find(14))
  end

end
