class Api::V1::AuthTokenController < ApplicationController
  def token
      if params[:client_secret].present? && params[:client_public].present?
        @app.user.regenerate_token
        @app.user.save
        render_response({ access_token: @app.user.authentication_token })
      else
        render_response('Unable to retrieve auth token! please check your keys', 401) && return
      end
  end
end
