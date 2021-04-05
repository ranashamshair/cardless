# frozen_string_literal: true

class Users::SessionsController < DeviseController
  layout 'application'

  include ApplicationHelper
  # include Recaptcha::Adapters::ViewMethods
  # include Recaptcha::Adapters::ControllerMethods
  prepend_before_action :require_no_authentication, only: %i[new create]
  prepend_before_action :allow_params_authentication!, only: :create
  prepend_before_action :verify_signed_out_user, only: :destroy
  prepend_before_action(only: %i[create destroy]) { request.env['devise.skip_timeout'] = true }
  # skip_before_action :authenticate_user!, :except => [:destroy]

  # caches_page :new

  # GET /resource/sign_in
  def new
    #   ENV['RECAPTCHA_SITE_KEY']
    #   ENV['RECAPTCHA_SECRET_KEY']
    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
    yield resource if block_given?
    respond_with(resource, serialize_options(resource))
  end

  # POST /resource/sign_in
  def create
    #   timezone = TIMEZONE
    #   timezone = cookies[:timezone] if cookies[:timezone].present?
    #   offset = params["offset"].present? ? params["offset"] : Time.now.in_time_zone(timezone).strftime("%:z")
    self.resource = warden.authenticate!(auth_options)
    yield resource if block_given?
    if resource.blank?
      set_flash_message!(:notice, :is_blocked)
      redirect_to root_path && return
    end
    set_flash_message!(:success, :signed_in) if resource.present?
    sign_in(resource_name, resource)
    if resource.admin?
      redirect_to admin_dashboard_index_path
    else
      redirect_to root_path
    end
  end

  # def try_again
  #   if params[:send_with]=='mobile'
  #     user = User.find(params[:id])
  #     user.direct_otp = rand(1_00000..9_99999)
  #     user.direct_otp_sent_at = DateTime.now.utc
  #     if user.save
  #       render status: 200, json:{success: 'Verified'}
  #     else
  #       render status: 404, json:{error: 'You are not Authorized for this action.'}
  #     end
  #   else
  #     @user = User.find(params[:id])
  #     if params[:check] == 'two-step'
  #       UserMailer.two_step_veification(@user).deliver_later
  #     else
  #       UserMailer.send_email_code(@user).deliver_later
  #     end
  #   end
  # end

  def login_verification
    result = false
    exceded_limit = false
    failed_attempts_checker = 0
    remaining_warning = ''
    if params[:type] == 'login'
      user = User.where.not(role: 'user').where(email: params[:email].try(:downcase)).first
      if user.present?
        if user.valid_password?(params[:password]) && user.failed_attempts != 6
          result = true
        else
          failed_attempts_count = user.failed_attempts + 1 if user.failed_attempts < 6
          if failed_attempts_count.present?
            failed_attempts_checker = failed_attempts_count
          else
            user.resend_unlock_instructions
            failed_attempts_checker = 6
          end
          if failed_attempts_count.present? && failed_attempts_count == 6
            return # Devise default unlock instruction method will trigger
          elsif failed_attempts_count.present? && failed_attempts_count < 6
            if failed_attempts_count == 4
              remaining_warning = '2'
            elsif failed_attempts_count == 5
              remaining_warning = '1'
            end
            user.update(failed_attempts: failed_attempts_count)
          end
        end
      end
    elsif params[:type] == 'two_step'
      user = User.find(current_user.id)
      result = user.direct_otp == params[:token]
    end
    if result
      render status: 200, json: { success: 'Verified' }
    elsif failed_attempts_checker == 6
      render status: 404, json: { error: 'exceded limit' }
    elsif [4, 5].include?(failed_attempts_checker)
      (render status: 404,
              json: { error: "Invalid password - You have #{remaining_warning} more attempt" })
    else
      (render status: 404,
              json: { error: 'You are not Authorized for this action.' })
    end
  end

  # DELETE /resource/sign_out
  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message! :notice, :signed_out if signed_out
    yield if block_given?
    respond_to_on_destroy
  end

  def user_from_email
    @user = User.not_customers.where(email: params[:user][:email]).last if params[:user][:email].present?
    if @user.present?
      render partial: 'users/sessions/merchants/user_from_email'
    else
      flash[:notice] = 'Email is not present in system.'
      redirect_to new_user_session_path
    end
  end

  def send_2factor_code
    @user = User.find(params[:user_id]) if params[:user_id].present?
    if params[:came_from].present? && (params[:came_from] == 'send_code' || params[:came_from] == 'resend_code')
      if params[:type].present?
        if params[:type] == 'email'
          if params[:from_reset].present? && params[:from_reset] == 'true'
            UserMailer.send_email_code(@user).deliver_later
          else
            UserMailer.two_step_veification(@user).deliver_later
          end
        elsif params[:type] == 'text'
          if params[:partner] == 'partner'
            @random_code = rand(100_000..999_999)
            @user.update(direct_otp: @random_code, direct_otp_sent_at: DateTime.now.utc)
            phone_number = @user.phone_number
            TextsmsWorker.perform_async(phone_number,
                                        "Your Two-Step Authentication Code for QuickCard: #{@random_code}")
          else
            @random_code = rand(1_000..9_999)
            @user.update(direct_otp: @random_code, direct_otp_sent_at: DateTime.now.utc)
            phone_number = @user.phone_number
            TextsmsWorker.perform_async(phone_number, "Your pin Code for new password is: #{@random_code}")
          end
        end
        render status: 200, json: { success: 'Sent' }
      else
        render status: 404, json: { error: 'Fail' }
      end
    elsif params[:came_from].present? && params[:came_from] == 'verify_code'
      if params[:code].present? && params[:code] == @user.direct_otp
        render status: 200, json: { success: 'Verified' }
      else
        render status: 404, json: { error: 'Wrong Code' }
      end
    elsif params[:password].present?
      if @user.update(password: params[:password], failed_attempts: 0, unlock_token: nil, locked_at: nil)
        flash[:success] = 'Password updated successfully!'
        redirect_to new_user_session_path
      else
        flash[:error] =
          current_user.present? ? current_user.errors.try(:full_messages).try(:first) : @user.try(:errors).try(:full_messages).try(:first)
        render partial: 'users/sessions/merchants/reset_password_div'
      end
    end
  end

  protected

  def sign_in_params
    devise_parameter_sanitizer.sanitize(:sign_in)
  end

  def serialize_options(resource)
    methods = resource_class.authentication_keys.dup
    methods = methods.keys if methods.is_a?(Hash)
    methods << :password if resource.respond_to?(:password)
    { methods: methods, only: [:password] }
  end

  def auth_options
    { scope: resource_name, recall: "#{controller_path}#new" }
  end

  def translation_scope
    'devise.sessions'
  end

  private

  # Check if there is no signed in user before doing the sign out.
  #
  # If there is no signed in user, it will set the flash message and redirect
  # to the after_sign_out path.
  def verify_signed_out_user
    if all_signed_out?
      set_flash_message! :notice, :already_signed_out

      respond_to_on_destroy
    end
  end

  def all_signed_out?
    users = Devise.mappings.keys.map { |s| warden.user(scope: s, run_callbacks: false) }

    users.all?(&:blank?)
  end

  def respond_to_on_destroy
    # We actually need to hardcode this as Rails default responder doesn't
    # support returning empty response on GET request
    respond_to do |format|
      format.all { head :no_content }
      format.any(*navigational_formats) { redirect_to root_path }
    end
  end

  def require_no_authentication
    assert_is_devise_resource!
    return unless is_navigational_format?

    no_input = devise_mapping.no_input_strategies

    authenticated = if no_input.present?
                      args = no_input.dup.push scope: resource_name
                      warden.authenticate?(*args)
                    else
                      warden.authenticated?(resource_name)
                    end

    if authenticated && resource = warden.user(resource_name)
      oauth_redirect and return unless session[:oauth_app].nil?

      flash[:alert] = if flash[:alert].present? && flash[:alert] == I18n.t('devise.failure.page_not_exist')
                        I18n.t('devise.failure.page_not_exist')
                      else
                        I18n.t('devise.failure.already_authenticated')
                      end
      redirect_to after_sign_in_path_for(resource)
    end
  end

  # def oauth_redirect
  #   if resource.present? && resource_name.present?
  #     session[:oauth_app]['token'] = resource.authentication_token
  #     session[:oauth_app]['wallet_id'] = resource.wallets.first.id
  #     sign_out(resource_name)
  #   end
  #   session[:oauth_app]['code'] = random_token
  #   redirect_to "#{session[:oauth_app]['redirect_uri']}?code=#{session[:oauth_app]['code']}"
  # end

  # def check_captcha
  #   signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
  #   unless verify_recaptcha()
  #     flash.delete(:recaptcha_error)
  #     redirect_to '/' , :notice => 'Unverified Recaptcha: Prove you aren\'t a robot!'
  #   end
  # end
end
