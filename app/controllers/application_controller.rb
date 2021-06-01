# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :redirect_maintain

  def redirect_maintain
    redirect_to root_path
  end
end
