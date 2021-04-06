# frozen_string_literal: true

class Merchant::BanksController < MerchantBaseController
  before_action :set_bank, only: %i[edit update]
  def index
    @banks = current_user.banks.all
  end

  def show
    @bank = Bank.find(params[:id])
  end

  def new
    @bank = Bank.new
  end

  def edit; end

  def create
    @bank = current_user.banks.build(bank_params)

    respond_to do |format|
      if @bank.save
        format.html { redirect_to merchant_bank_path(id: @bank.id), notice: 'Bank was successfully created.' }
        format.json { render :show, status: :created, location: @bank }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @bank.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @bank.update(bank_params)
        format.html { redirect_to merchant_bank_path(id: @bank.id), notice: 'Bank was successfully updated.' }
        format.json { render :show, status: :ok, location: @bank }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @bank.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @bank.destroy
    respond_to do |format|
      format.html { redirect_to merchant_banks_url, notice: 'Bank was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_bank
    @bank = Bank.find(params[:id])
  end

  def bank_params
    params.require(:bank).permit(:user_id, :iban, :currency, :user_name, :bank_name)
  end
end
