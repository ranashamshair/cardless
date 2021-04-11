# frozen_string_literal: true

class Merchant::WithdrawsController < MerchantBaseController
  before_action :set_withdraw, only: %i[show edit update destroy]
  before_action :authenticate_user!
  include WithdrawsHelper
  # GET /withdraws
  # GET /withdraws.json
  def index
    @pagy, @withdraws = pagy(current_user.withdraws.all.order(created_at: :desc))
  end

  # GET /withdraws/1
  # GET /withdraws/1.json
  def show; end

  # GET /withdraws/new
  def new
    @banks = current_user.banks.all

    @withdraw = Withdraw.new
  end

  # GET /withdraws/1/edit
  def edit; end

  # POST /withdraws
  # POST /withdraws.json
  def create
    wallet = current_user.wallets.primary.first
    if withdraw_params[:amount].to_f > 0 && withdraw_params[:amount].to_f < wallet.balance.to_f
      @withdraw = Withdraw.new(withdraw_params)
      @withdraw.user = current_user
      @withdraw.name = "#{current_user.first_name} #{current_user.last_name}"
      @withdraw.is_payed = false
      @withdraw.ref_id = "WID-#{SecureRandom.hex.first(6)}"
      respond_to do |format|
        if @withdraw.save

          distro = Wallet.distro.first
          fee = Fee.first
          withdraw_fee = fee.withdraw.to_f
          total = withdraw_fee + @withdraw.amount
          tx = Transaction.create(
            amount: @withdraw.amount,
            net_amount: total,
            fee: withdraw_fee,
            total_fee: withdraw_fee,
            action: 2,
            status: 1,
            main_type: 1,
            sender_id: current_user.id,
            sender_wallet_id: wallet.id,
            sender_balance: wallet.balance.to_f - total.to_f,
            ref_id: SecureRandom.hex,
            bank_id: @withdraw.bank_id
          )
          Transaction.create(
            amount: withdraw_fee,
            net_amount: withdraw_fee,
            sender_id: current_user.id,
            sender_wallet_id: wallet.id,
            sender_balance: wallet.balance.to_f - total.to_f,
            receiver_id: distro.user_id,
            receiver_wallet_id: distro.id,
            receiver_balance: distro.balance + withdraw_fee,
            main_type: 6,
            action: 0,
            status: 1,
            ref_id: SecureRandom.hex,
            bank_id: @withdraw.bank_id
          )
          @withdraw.transaction_id = tx.id
          @withdraw.save
          wallet.update(balance: wallet.balance - total)
          distro.update(balance: distro.balance + withdraw_fee)
          format.html { redirect_to merchant_dashboard_index_path, notice: 'Withdraw was successfully created.' }
        else
          format.html { redirect_to merchant_dashboard_index_path, notice: @withdraw.errors.messages }
        end
      end
    else
      respond_to do |format|
        format.html do
          redirect_to merchant_dashboard_index_path, notice: 'Something went wrong please try again later!'
        end
      end
    end
  end

  # PATCH/PUT /withdraws/1
  # PATCH/PUT /withdraws/1.json
  def update
    respond_to do |format|
      if @withdraw.update(withdraw_params)
        format.html { redirect_to @withdraw, notice: 'Withdraw was successfully updated.' }
        format.json { render :show, status: :ok, location: @withdraw }
      else
        format.html { render :edit }
        format.json { render json: @withdraw.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /withdraws/1
  # DELETE /withdraws/1.json
  def destroy
    @withdraw.destroy
    respond_to do |format|
      format.html { redirect_to withdraws_url, notice: 'Withdraw was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_withdraw
    @withdraw = Withdraw.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def withdraw_params
    params.require(:withdraw).permit(:name, :user_id, :bank_id, :is_payed, :amount)
  end
end
