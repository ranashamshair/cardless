# frozen_string_literal: true

class Admin::MerchantsController < AdminBaseController
  before_action :find_merchant, only: %i[edit update]

  def index
    @pagy, @merchants = pagy(User.merchant.includes(:payment_gateway))
  end

  def edit; end

  def update
    respond_to do |format|
      if @merchant.update(merchant_params)
        format.html { redirect_to admin_merchants_path, notice: 'Merchant was successfully updated.' }
        format.json { render :show, status: :ok, location: @merchant }
      else
        format.html { render :edit }
        format.json { render json: @merchant.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def find_merchant
    @merchant = User.find(params[:id])
  end

  def merchant_params
    params.require(:user).permit(:first_name, :last_name, :country, :city, :state, :phone_number, :company, :role, :is_active, :email, :password, :password_confirmation, :street_address, :zip_code, :payment_gateway_id)
  end
end
