# frozen_string_literal: true

class AdminBaseController < ActionController::Base
  layout 'admin'
  include Pagy::Backend
  before_action :check_admin
  before_action :authenticate_user!


  def check_admin
    redirect_to root_path unless current_user.admin?
  end
end
