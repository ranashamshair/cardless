# frozen_string_literal: true

class Merchant::DashboardController < MerchantBaseController
  before_action :find_merchant, only: %i[edit update]
  def index
    reserve_release = current_user.reserve_schedules.where('DATE(release_date) = ?', Date.today)
    @reserve_release_amount = reserve_release.pluck(:amount).sum if reserve_release.present?
  end

  def fee_structure
    @fee = Fee.last
  end

  def show
    @user = current_user
  end

  def edit
    @merchant = current_user
  end

  def update
    respond_to do |format|
      if @merchant.update_without_password(merchant_params, current_user)
        bypass_sign_in(@merchant)
        format.html { redirect_to merchant_dashboard_index_path, notice: ' successfully updated.' }
        format.json { render :show, status: :ok, location: @merchant }
      else
        format.html { render :edit, notice: 'passord not mtched' }
        format.json { render json: @merchant.errors, status: :unprocessable_entity }
      end
    end
  end

  def api_key
  end

  def settings
  end

  private

  def find_merchant
    @merchant = current_user
  end

  def merchant_params
    params.require(:user).permit(:first_name, :last_name, :country, :city, :state, :phone_number, :company, :role,
                                 :email, :password, :password_confirmation, :street_address, :zip_code)
  end
end
