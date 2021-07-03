# frozen_string_literal: true

class Admin::FeesController < AdminBaseController
  def index
    @fee = Fee.first
    @fee = Fee.new if @fee.blank?
    @url = admin_fee_path(@fee) if @fee.id.present?
    @url = admin_fees_path if @fee.id.blank?
  end

  def create
    @fee = Fee.new(fee_params)
    if @fee.save
      redirect_to admin_fees_path
    else
      redirect_to admin_fees_path
    end
  end

  def update
    @fee = Fee.find(params[:id])
    if @fee.update(fee_params)
      redirect_to admin_fees_path
    else
      redirect_to admin_fees_path
    end
  end

  private

  def fee_params
    params.fetch(:fee).permit(:sale_credit_bank,:refund, :sale_debit_bank, :sale_credit_merchant, :sale_debit_merchant,
                              :sale_credit_bank_percent, :account_transfer, :sale_debit_bank_percent, :sale_credit_merchant_percent,
                              :sale_debit_merchant_percent, :withdraw, :reserve, :days, :reward_amount)
  end
end
