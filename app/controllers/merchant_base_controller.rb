# frozen_string_literal: true

class MerchantBaseController < ActionController::Base
  layout 'merchant'
  include Pagy::Backend
  before_action :check_merchant
  before_action :authenticate_user!


  def check_merchant
    redirect_to root_path unless current_user.merchant?
  end

  def check_active
    if !current_user.is_active
      flash[:notice] = "Your are not allowed to perform this action. "
      redirect_to merchant_dashboard_index_path
    end
  end
end
