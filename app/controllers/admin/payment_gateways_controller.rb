# frozen_string_literal: true

class Admin::PaymentGatewaysController < AdminBaseController
  before_action :find_gateway, only: %i[show edit update]
   skip_before_action :verify_authenticity_token


  def index
    @pagy, @payment_gateways = pagy(PaymentGateway.all)
  end

  def show; end

  def edit; end

  def new
    @payment_gateway = PaymentGateway.new
  end

  def create
    params[:payment_gateway][:gateway_type] = params[:payment_gateway][:gateway_type].to_i
    @payment_gateway = PaymentGateway.new(payment_gateway_params)
    respond_to do |format|
      if @payment_gateway.save
        format.html { redirect_to admin_payment_gateways_path, notice: 'Payment Gateway was successfully added.' }
        format.json { render :show, status: :ok, location: @payment_gateway }
      else
        format.html { render :edit }
        format.json { render json: @payment_gateway.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      params[:payment_gateway][:gateway_type] = params[:payment_gateway][:gateway_type].to_i
      if @payment_gateway.update(payment_gateway_params)
        format.html { redirect_to admin_payment_gateways_path, notice: 'Payment Gateway was successfully updated.' }
        format.json { render :show, status: :ok, location: @payment_gateway }
      else
        format.html { render :edit }
        format.json { render json: @payment_gateway.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def find_gateway
    @payment_gateway = PaymentGateway.find(params[:id])
  end

  def payment_gateway_params
    params.require(:payment_gateway).permit( :gateway_type, :name, :client_secret, :client_id, :is_block, :is_deleted, :merchant_id, :base_url, :secret_word, :redirect_url)
  end
end
