# frozen_string_literal: true

class Users::RegistrationsController < DeviseController
  # prepend_before_action :require_no_authentication, only: [:new, :create, :cancel, :user_signup ,:merchant_signup]
  # prepend_before_action :authenticate_scope!, only: [:edit, :update, :destroy]
  # prepend_before_action :set_minimum_password_length, only: [:new, :edit]

  layout 'application'

  # GET /resource/sign_up
  def new
    build_resource({})
    yield resource if block_given?
    respond_with resource
  end

  def create
    build_resource(sign_up_params)
    begin
      resource.merchant!
      resource.regenerate_token
      resource.create_oauth_app
      resource.save
      sign_up(resource_name, resource)
      respond_with resource, location: after_sign_up_path_for(resource)
    rescue StandardError => e
      render :new
      set_flash_message :danger, :valid_user
    end
    #   if resource.merchant!
    #     yield resource if block_given?
    #     if resource.persisted?
    #       if resource.active_for_authentication?
    #         set_flash_message! :notice, :signed_up
    #         # if session[:oauth_app].present?
    #         #   oauth_redirect and return
    #         # elsif self.resource.is_block == true
    #         #   signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    #         #   redirect_to new_user_session_path
    #         #   set_flash_message! :notice, :is_blocked
    #         # else
    #           sign_up(resource_name, resource)
    #           respond_with resource, location: after_sign_up_path_for(resource)
    #         # end
    #       else
    #         # if session[:oauth_app].present?
    #         #   oauth_redirect and return
    #         # end
    #         set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
    #         expire_data_after_sign_in!
    #         respond_with resource, location: after_inactive_sign_up_path_for(resource)
    #       end
    #     else
    #       clean_up_passwords resource
    #       set_minimum_password_length
    #       respond_with resource
    #     end
    #   else
    #     redirect_to new_user_session_path
    #     set_flash_message :danger ,:valid_user
    #   end
  end

  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :country, :city, :state, :phone_number, :company, :role,
                                 :is_active, :email, :password, :password_confirmation, :street_address, :zip_code, :org_name, :business_type)
  end

  def account_update_params
    params.require(:user).permit(:first_name, :last_name, :country, :city, :state, :phone_number, :company, :role,
                                 :is_active, :email, :password, :password_confirmation, :street_address, :zip_code, :org_name, :business_type)
  end

  # def user_signup
  #   build_resource({})
  #   respond_to :js
  # end
  # def merchant_signup
  #   build_resource({})
  #   respond_to :js
  # end

  def build_resource(hash = nil)
    self.resource = resource_class.new_with_session(hash || {}, session)
  end

  # Signs in a user on sign up. You can overwrite this method in your own
  # RegistrationsController.
  def sign_up(resource_name, resource)
    sign_in(resource_name, resource)
  end

  # The path used after sign up. You need to overwrite this method
  # in your own RegistrationsController.
  def after_sign_up_path_for(resource)
    after_sign_in_path_for(resource)
  end

  # The path used after sign up for inactive accounts. You need to overwrite
  # this method in your own RegistrationsController.
  def after_inactive_sign_up_path_for(resource)
    scope = Devise::Mapping.find_scope!(resource)
    router_name = Devise.mappings[scope].router_name
    context = router_name ? send(router_name) : self
    context.respond_to?(:root_path) ? context.root_path : '/'
  end

  # The default url to be used after updating a resource. You need to overwrite
  # this method in your own RegistrationsController.
  def after_update_path_for(resource)
    signed_in_root_path(resource)
  end

  # Authenticates the current scope and gets the current resource from the session.
  def authenticate_scope!
    send(:"authenticate_#{resource_name}!", force: true)
    self.resource = send(:"current_#{resource_name}")
  end

  def account_update_params
    devise_parameter_sanitizer.sanitize(:account_update)
  end

  # def translation_scope
  #   'devise.registrations'
  # end
end
