# frozen_string_literal: true

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
    
    # card_bin = Card.neutrino_post(card_number.first(6))
    card_info = {
            number: params[:transaction][:card_number],
            month: params[:transaction][:exp_date].first(2),
            year: "20#{params[:transaction][:exp_date].last(2)}",
            exp_date: "#{params[:transaction][:exp_date].first(2)}/#{params[:transaction][:exp_date].last(2)}"
    }
    card1 = Payment::DistroCard.new(card_info,nil,customer.id)
    card = Card.create(first6: card_number.first(6), last4: card_number.last(4),exp_date: params[:transaction][:exp_date], user_id: customer.id,brand: "VISA", card_type: "credit", fingerprint: card1.fingerprint, distro_token: card1.qc_token)
    fee = Fee.first


    if card.card_type.downcase == 'credit'
      bank_fee = fee.sale_credit_bank.to_f
      bank_fee_percent = params[:transaction][:amount].to_f * fee.sale_credit_bank_percent.to_f / 100
      total_bank_fee = bank_fee.to_f + bank_fee_percent.to_f
      merchant_fee = fee.sale_credit_merchant.to_f
      merchant_fee_percent = params[:transaction][:amount].to_f * fee.sale_credit_merchant_percent.to_f / 100
      total_merchant_fee = merchant_fee.to_f + merchant_fee_percent.to_f
    else
      bank_fee = fee.sale_debit_bank.to_f
      bank_fee_percent = params[:transaction][:amount].to_f * fee.sale_debit_bank_percent.to_f / 100
      total_bank_fee = bank_fee.to_f + bank_fee_percent.to_f
      merchant_fee = fee.sale_debit_merchant.to_f
      merchant_fee_percent = params[:transaction][:amount].to_f * fee.sale_debit_merchant_percent.to_f / 100
      total_merchant_fee = merchant_fee.to_f + merchant_fee_percent.to_f
    end
    reserve = params[:transaction][:amount].to_f * fee.reserve.to_f / 100
    total_fee = total_merchant_fee.to_f + total_bank_fee.to_f
    issue_tx = Transaction.create(
      amount: params[:transaction][:amount],
      receiver_wallet_id: customer_wallet.id,
      receiver_id: customer.id,
      receiver_balance: customer_wallet.balance.to_f + params[:transaction][:amount].to_f,
      main_type: 2,
      first6: card.first6,
      last4: card.last4,
      ref_id: SecureRandom.hex,
      status: 0,
      action: 1,
      card_id: card.id
    )
    charge = charge_on_gateway(card, customer)

    return redirect_to merchant_dashboard_index_path, notice: charge[:message] if charge[:error_code].present?
    issue_tx.update(charge_id: charge[:charge], status: 1)
    customer_wallet.update(balance: customer_wallet.balance.to_f + params[:transaction][:amount].to_f)
    merchant_wallet = current_user.wallets.primary.first
    reserve_wallet = current_user.wallets.reserve.first
    net_amount = params[:transaction][:amount].to_f - total_fee.to_f - reserve.to_f

    transfer_tx = Transaction.create(
      amount: params[:transaction][:amount],
      receiver_wallet_id: merchant_wallet.id,
      receiver_id: current_user.id,
      sender_id: customer.id,
      charge_id: charge[:charge],
      sender_wallet_id: customer_wallet.id,
      receiver_balance: merchant_wallet.balance.to_f + net_amount.to_f,
      sender_balance: customer_wallet.balance.to_f - params[:transaction][:amount].to_f,
      main_type: 0,
      action: 0,
      first6: card.first6,
      last4: card.last4,
      ref_id: SecureRandom.hex,
      status: 1,
      card_id: card.id,
      fee: total_merchant_fee.to_f,
      total_fee: total_merchant_fee.to_f + total_bank_fee.to_f,
      bank_fee: total_bank_fee.to_f,
      reserve_money: reserve.to_f,
      net_amount: net_amount.to_f
    )
    if total_fee.to_f > 0
      wallet = Wallet.distro.first
      fee_tx = Transaction.create(
        amount: total_fee.to_f,
        net_amount: total_fee.to_f,
        ref_id: SecureRandom.hex,
        action: 0,
        main_type: 5,
        status: 1,
        sender_wallet_id: merchant_wallet.id,
        receiver_wallet_id: wallet.id,
        sender_id: current_user.id,
        receiver_id: wallet.user_id,
        receiver_balance: wallet.balance.to_f + total_fee.to_f
      )
    end
    if fee.reserve.to_f > 0
      reserve_tx = Transaction.create(
        amount: reserve,
        net_amount: reserve,
        receiver_wallet_id: reserve_wallet.id,
        receiver_id: current_user.id,
        sender_id: customer.id,
        sender_wallet_id: merchant_wallet.id,
        receiver_balance: reserve_wallet.balance.to_f + reserve.to_f,
        sender_balance: merchant_wallet.balance.to_f + net_amount.to_f,
        main_type: 3,
        action: 0,
        ref_id: SecureRandom.hex,
        status: 1
      )
      if reserve_tx.present?
        ReserveSchedule.create(transaction_id: transfer_tx.id, reserve_tx_id: reserve_tx.id, amount: reserve,
                              release_date: DateTime.now + fee.days, tx_date: transfer_tx.created_at, user_id: current_user.id, reserve_status: 'pending')
      end
      reserve_wallet.update(balance: reserve_wallet.balance.to_f + reserve.to_f)
    end

    customer_wallet.update(balance: customer_wallet.balance.to_f - params[:transaction][:amount].to_f)
    merchant_wallet.update(balance: (merchant_wallet.balance.to_f + net_amount.to_f))
    redirect_to merchant_dashboard_index_path, notice: 'success'
  end


  def refund
    @fee = Fee.last
  end

  private

  def charge_on_gateway(card, customer)
    merchant = current_user

    trans_payment_gateway = if merchant.payment_gateway.present?
                              merchant.payment_gateway
                            else
                              PaymentGateway.red_sys.first
                            end

    card_info = Payment::DistroCard.new({ fingerprint: card.fingerprint }, card.distro_token, customer.id)

    charge_gateway = Payment::Gateway.new(trans_payment_gateway)

    charge_gateway.charge({
                            amount: params[:transaction][:amount], #24.44$
                            cvv: params[:transaction][:cvc], # 231
                            card_name: params[:transaction][:name], # John Sins
                            card_number: card_info.number, # 4242424242424242
                            expiry_date: "#{card_info.month}#{card_info.year.last(2)}", # 0728
                            email: customer.email, # abc@gmail.com
                            customer: customer
                                   })

  end
end
