# frozen_string_literal: true

class Api::V1::SalesController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :validate_token

  def validate_token
    @user = User.where(authentication_token: params[:access_token]).last
    render json: { message: 'Access token not found check it', status: 401 } unless @user.present?
  end

  def virtual_terminal
    validate_params(
      name: params[:transaction][:name],
      email: params[:transaction][:email],
      phone: params[:transaction][:phone],
      amount: params[:transaction][:amount],
      card_number: params[:transaction][:card_number],
      exp_date: params[:transaction][:exp_date],
      cvc: params[:transaction][:cvc]
    )

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
    card = Card.create(first6: card_number.first(6), last4: card_number.last(4),
                       exp_date: params[:transaction][:exp_date], user_id: customer.id, brand: 'visa', card_type: 'credit')
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
      status: 1,
      action: 1,
      card_id: card.id
    )
    customer_wallet.update(balance: customer_wallet.balance.to_f + params[:transaction][:amount].to_f)
    merchant_wallet = @user.wallets.primary.first
    reserve_wallet = @user.wallets.reserve.first
    net_amount = params[:transaction][:amount].to_f - total_fee.to_f - reserve.to_f

    transfer_tx = Transaction.create(
      amount: params[:transaction][:amount],
      receiver_wallet_id: merchant_wallet.id,
      receiver_id: @user.id,
      sender_id: customer.id,
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
        sender_id: @user.id,
        receiver_id: wallet.user_id,
        receiver_balance: wallet.balance.to_f + total_fee.to_f
      )
    end
    reserve_tx = Transaction.create(
      amount: reserve,
      net_amount: reserve,
      receiver_wallet_id: reserve_wallet.id,
      receiver_id: @user.id,
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
                             release_date: DateTime.now + fee.days, tx_date: transfer_tx.created_at, user_id: @user.id, reserve_status: 'pending')
    end
    customer_wallet.update(balance: customer_wallet.balance.to_f - params[:transaction][:amount].to_f)
    merchant_wallet.update(balance: (merchant_wallet.balance.to_f + net_amount.to_f))
    reserve_wallet.update(balance: reserve_wallet.balance.to_f + reserve.to_f)
    render json: { message: 'Payment successful ', status: 200, ref_id: issue_tx[:ref_id] }
  end

  private

  def validate_params(args)
    args.each do |name, value|
      raise ArgumentError, "Missing required parameter: #{name}" if value.blank?
    end

    value = args[:name]
    raise ArgumentError, "Invalid name : #{value}" unless value.length > 4

    value = args[:email]
    raise ArgumentError, "Invalid Email: #{value}" unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

    value = args[:amount]
    raise ArgumentError, "Invalid Amount : #{value}" unless Integer(value)

    value = args[:card_number]
    raise ArgumentError, "Invalid Card number : #{value}" unless Integer(value) && value.size == 16

    value = args[:exp_date]
    raise ArgumentError, "Invalid Date : #{value}" unless value.length == 5

    date_checker(value)

    value = args[:cvc]
    raise ArgumentError, "Invalid CVC  : #{value}" unless (value.size == 3 || value.size == 4) && Integer(value)
  end

  def date_checker(value)
    date = value.split('/')
    today = Time.now
    year = today.year.to_s
    year = year.slice(2..3).to_i

    raise ArgumentError, 'Invalid date }' unless Integer(date[0]) && Integer(date[1])

    if date[0].to_i <= today.month && date[1].to_i < year
      raise ArgumentError, "Invalid month  : #{date[0]}"
    elsif date[0].to_i > today.month && date[1].to_i < year
      raise ArgumentError, "Invalid year  : #{date[1]}"
    elsif date[0].to_i > 12
      raise ArgumentError, "Invalid date  : #{date[1]}"
    elsif date[0].to_i < today.month && date[1].to_i == year
      raise ArgumentError, "Invalid date  : #{date[1]}"
    end
  end
end