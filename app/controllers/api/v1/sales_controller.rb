# frozen_string_literal: true

class Api::V1::SalesController < ApplicationController
  include ExceptionHandler

  skip_before_action :verify_authenticity_token

  before_action :validate_token

  def validate_token
    raise ArgumentError, "Missing access token" if params[:access_token].blank?
    @user = User.where(authentication_token: params[:access_token]).last
    raise ArgumentError, "Invalid access token" unless @user.present?
  end

  def virtual_terminal
    validate_params(
      name: params[:transaction].try(:[],:name),
      email: params[:transaction].try(:[],:email),
      phone: params[:transaction].try(:[],:phone),
      amount: params[:transaction].try(:[],:amount),
      card_number: params[:transaction].try(:[],:card_number),
      exp_date: params[:transaction].try(:[],:exp_date),
      cvc: params[:transaction].try(:[],:cvc)
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
    card_bin = Card.neutrino_post(card_number.first(6))
    card_info = {
            number: params[:transaction][:card_number],
            month: params[:transaction][:exp_date].first(2),
            year: "20#{params[:transaction][:exp_date].last(2)}",
            exp_date: "#{params[:transaction][:exp_date].first(2)}/#{params[:transaction][:exp_date].last(2)}"
    }
    if card_bin.present? && card_bin["valid"]
      card1 = Payment::DistroCard.new(card_info,nil,customer.id)
      card = Card.create(first6: card_number.first(6), last4: card_number.last(4),exp_date: params[:transaction][:exp_date], user_id: customer.id,brand: card_bin["card-brand"], card_type: card_bin["card-type"], fingerprint: card1.fingerprint, distro_token: card1.qc_token)
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

      transaction_creator = TransactionCreator.new(
        @user,
        customer,
        card,
        params[:transaction][:amount],
        params[:transaction][:cvc]
      )
      charge = transaction_creator.charge_on_gateway

      issue_tx.update(payment_gateway_id: charge[:payment_gateway_id])
      raise StandardError.new(charge[:message]) if charge[:error_code].present?
      issue_tx.update(charge_id: charge[:charge], status: 1)
      customer_wallet.update(balance: customer_wallet.balance.to_f + params[:transaction][:amount].to_f)
      merchant_wallet = @user.wallets.primary.first
      reserve_wallet = @user.wallets.reserve.first
      net_amount = params[:transaction][:amount].to_f - total_fee.to_f - reserve.to_f

      transfer_tx = Transaction.create(
        amount: params[:transaction][:amount],
        receiver_wallet_id: merchant_wallet.id,
        receiver_id: @user.id,
        sender_id: customer.id,
        charge_id: charge[:charge],
        payment_gateway_id: charge[:payment_gateway_id],
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
        wallet.update(balance: wallet.balance.to_f + total_fee.to_f)
      end
      if fee.reserve.to_f > 0
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
        reserve_wallet.update(balance: reserve_wallet.balance.to_f + reserve.to_f)
      end
      customer_wallet.update(balance: customer_wallet.balance.to_f - params[:transaction][:amount].to_f)
      merchant_wallet.update(balance: (merchant_wallet.balance.to_f + net_amount.to_f))

      reward = @user.rewards.where(payed: false).first
      if reward.present?
        reward.update(amount: reward.amount + params[:transaction][:amount].to_f)
      else
        Reward.create(
          amount: params[:transaction][:amount].to_f,
          user_id: @user.id
        )
      end
      TransactionMailer.customer_email(customer, @user, transfer_tx).deliver_now
      TransactionMailer.merchant_email(customer, @user, transfer_tx).deliver_now
      render json: { message: 'Payment successful ', success: true, status: 200, ref_id: transfer_tx.ref_id }
    else
      render json: { message: 'Invalid Card', success: false, status: 200, ref_id: "" }
    end
  end

  private

  def validate_params(args)
    args.each do |name, value|
      raise ArgumentError, "Missing required parameter: #{name}" if value.blank?
    end

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

    raise ArgumentError, 'Invalid date' unless Integer(date[0]) && Integer(date[1])

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
