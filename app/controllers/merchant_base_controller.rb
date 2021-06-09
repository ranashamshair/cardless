# frozen_string_literal: true

class MerchantBaseController < ActionController::Base
  layout 'merchant'
  include Pagy::Backend
  before_action :check_merchant
  before_action :authenticate_user!


  def check_merchant
    redirect_to root_path unless current_user.merchant?
  end
end
