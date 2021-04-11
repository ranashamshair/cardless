class Api::V1::AuthTokenController < ApplicationController
  skip_before_action :verify_authenticity_token

  def token
    if params[:client_secret].present? && params[:client_public].present?
      user = User.where(secret_key: params[:client_secret], public_key: params[:client_public]).first
      if user.present?
        user.regenerate_token
        user.save
        render json: { access_token: user.authentication_token }
      else
        render json: { message: 'Unable to retrieve auth token! please check your keys', status: 401 }
      end
    else
      render json: { message: 'Unable to retrieve auth token! please check your keys', status: 401 }
    end
  end
end
