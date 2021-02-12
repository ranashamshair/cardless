class Merchant::SaleController < MerchantBaseController
  def index
    @transaction = Transaction.new
  end

  def create
    customer = User.customer.where(email: params[:transaction][:email]).first
    if customer.blank?
      password = SecureRandom.hex
      customer = User.create(
        email: params[:transaction][:email], 
        first_name: params[:transaction][:name],
        phone_number: params[:transaction][:phone],
        street_address: params[:transaction][:street_address],
        city: params[:transaction][:city],
        country: params[:transaction][:country],
        zip_code: params[:transaction][:zip_code],
        role: :customer,
        password: password, 
        password_confirmation: password
        )
    end
    customer_wallet = customer.wallets.primary.first
    card_number = params[:transaction][:card_number]
    card = Card.create(first6: card_number.first(6), last4: card_number.last(4), exp_date: params[:transaction][:exp_date], user_id: customer.id)
    issue_tx = Transaction.create(
      amount: params[:transaction][:amount],
      receiver_wallet_id: customer_wallet.id, 
      receiver_id: customer.id, 
      receiver_balance: customer_wallet.balance.to_f + params[:transaction][:amount].to_f,
      main_type: 2,
      first6: card.first6,
      last4: card.last4,
      ref_id: SecureRandom.hex,
      status: 1,
      action: 1,
      card_id: card.id
      )
    customer_wallet.update(balance: customer_wallet.balance.to_f + params[:transaction][:amount].to_f)
    merchant_wallet = current_user.wallets.primary.first
    transfer_tx = Transaction.create(
      amount: params[:transaction][:amount],
      receiver_wallet_id: merchant_wallet.id, 
      receiver_id: current_user.id, 
      sender_id: customer.id,
      sender_wallet_id: customer_wallet.id,
      receiver_balance: merchant_wallet.balance.to_f + params[:transaction][:amount].to_f,
      sender_balance: customer_wallet.balance.to_f - params[:transaction][:amount].to_f,
      main_type: 0,
      action: 0,
      first6: card.first6,
      last4: card.last4,
      ref_id: SecureRandom.hex,
      status: 1,
      card_id: card.id
      )
    customer_wallet.update(balance: customer_wallet.balance.to_f - params[:transaction][:amount].to_f)
    merchant_wallet.update(balance: merchant_wallet.balance.to_f + params[:transaction][:amount].to_f)
    redirect_to merchant_dashboard_index_path, notice: "success"
      
  end

end
