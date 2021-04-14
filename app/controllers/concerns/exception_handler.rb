module ExceptionHandler
  extend ActiveSupport::Concern

  # Define custom error subclasses - rescue catches `StandardErrors`
  class AuthenticationError < StandardError; end
  class UserNotFoundError < StandardError; end
  class UserDisabledError < StandardError; end

  included do
    # Define custom handlers
    rescue_from ExceptionHandler::AuthenticationError, with: :unauthorized_request
    rescue_from ArgumentError, with: :four_zero_zero

    rescue_from ActiveRecord::RecordNotFound do |e|
      # log(e)
      render json: { success: false, message: 'Invalid parameters provided. Check your request parameters!' }, status: :ok
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      # log(e)
      render json: { success: false, message: 'Wrong parameters provided. Invalid record requested!' }, status: :ok
    end

    rescue_from StandardError do |e|
      # log(e)
      render json: jsonData(e), status: :ok
    end

    rescue_from UserDisabledError do |e|
      # pushToSlack("Inactive User Login attempted with email: #{request.params["email"]} at #{request.url}")
      render json: { success: false, message: 'Your account is disabled! Please contact app administrator for further assistance!' }, status: :ok
    end

    rescue_from UserNotFoundError do |e|
      # pushToSlack("Invalid Login attempted with email: #{request.params["email"]} at #{request.url}")
      render json: { success: false, message: 'Sorry, No account found with entered email, You can signup for a new account below.' }, status: :ok
    end

    rescue_from Stripe::CardError do |e|
      # Since it's a decline, Stripe::CardError will be caught
      body = e.json_body
      err  = body[:error]
      msg = "Stripe Card Declined => "
      msg += "Status is: #{e.http_status}\n"
      msg += "Type is: #{err[:type]}\n"
      msg += "Charge ID is: #{err[:charge]}\n"
      # The following fields are optional
      msg += "Code is: #{err[:code]}\n" if err[:code]
      msg += "Decline code is: #{err[:decline_code]}\n" if err[:decline_code]
      msg += "Param is: #{err[:param]}\n" if err[:param]
      msg += "Message is: #{err[:message]}\n" if err[:message]
      # pushToSlack(msg)
      render json: { success: false, message: "Card Error: Card charge declined with code - #{err[:decline_code]}" }, status: :ok
    end

    # rescue_from Stripe::RateLimitError do |e|
    #   # Too many requests made to the API too quickly
    #   pushToSlack("Stripe::RateLimitError: " + e.to_json.to_s)
    #   render json: { success: false, message: 'Your consective requests quota maxed out. Try again later!' }, status: :ok
    # end

    rescue_from Stripe::InvalidRequestError do |e|
      # Invalid parameters were supplied to Stripe's API
      # pushToSlack("Stripe::InvalidRequestError: " + e.to_json.to_s)
      render json: { success: false, message: I18n.t("api.registrations.invalid_card_data") }, status: :ok
    end

    # rescue_from Stripe::AuthenticationError do |e|
    #   # Authentication with Stripe's API failed
    #   # (maybe you changed API keys recently)
    #   pushToSlack("Stripe::AuthenticationError: " + e.to_json.to_s)
    #   render json: { success: false, message: 'Network Error! Try again!' }, status: :ok
    # end

    # rescue_from Stripe::APIConnectionError do |e|
    #   # Network communication with Stripe failed
    #   pushToSlack("Stripe::APIConnectionError: " + e.to_json.to_s)
    #   render json: { success: false, message: 'Network Error! Try again!' }, status: :ok
    # end

    rescue_from Stripe::StripeError do |e|
      # Display a very generic error to the user, and maybe send
      # yourself an email
      # pushToSlack("StripeError: !" + e.to_json.to_s)
      render json: { success: false, message: 'Card Charge didn\'t go through. Try again!' }, status: :ok
    end
  end

  private

  # JSON response with message; Status code 400 - Bad Request
  def four_zero_zero(e)
    render json: jsonData(e), status: :bad_request
  end

  # JSON response with message; Status code 422 - unprocessable entity
  def four_twenty_two(e)
    render json: jsonData(e), status: :unprocessable_entity
  end

  # JSON response with message; Status code 401 - Unauthorized
  def four_ninety_eight(e)
    render json: jsonData(e), status: :invalid_token
  end

  # JSON response with message; Status code 401 - Unauthorized
  def four_zero_one(e)
    render json: jsonData(e), status: :invalid_token
  end

  # JSON response with message; Status code 401 - Unauthorized
  def unauthorized_request(e)
    render json: jsonData(e), status: :unauthorized
  end

  def log(exc)
    back_trace = exc.backtrace.select { |x| x.match(Rails.application.class.parent_name.downcase)}.first
    error = {Exception: exc.to_s ,URL: request.url.to_s, PARAMS: request.params.to_s, BACKTRACE: back_trace.to_s}.to_s
    pushToSlack(error)
  end

  def jsonData(exc)
    # log(exc)
    # p "EXCEPTION OCCURED: ", exc
    return { success: false, message: exc.message }
  end
end