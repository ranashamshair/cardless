class Merchant::WithdrawsController < MerchantBaseController
  before_action :set_withdraw, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  include WithdrawsHelper
  # GET /withdraws
  # GET /withdraws.json
  def index
    @pagy, @withdraws = pagy(current_user.withdraws.all.order(created_at: :desc))
  end

  # GET /withdraws/1
  # GET /withdraws/1.json
  def show
  end

  # GET /withdraws/new
  def new
    @withdraw = Withdraw.new
  end

  # GET /withdraws/1/edit
  def edit
  end

  # POST /withdraws
  # POST /withdraws.json
  def create
    if withdraw_params[:amount].to_f > 0 && withdraw_params[:amount].to_f < current_user.wallets.primary.first.balance.to_f
      @withdraw = Withdraw.new(withdraw_params)
      @withdraw.user = current_user
      @withdraw.name = "#{current_user.first_name} #{current_user.last_name}"
      @withdraw.is_payed = false
      @withdraw.ref_id = "WID-#{SecureRandom.hex.first(6)}"
      respond_to do |format|
        if @withdraw.save
          format.html { redirect_to merchant_dashboard_index_path, notice: 'Withdraw was successfully created.' }
        else
          format.html { redirect_to merchant_dashboard_index_path, notice: @withdraw.errors.messages }
        end
      end
    else
      respond_to do |format|
          format.html { redirect_to merchant_dashboard_index_path, notice: 'Something went wrong please try again later!' }
      end
    end
  end

  # PATCH/PUT /withdraws/1
  # PATCH/PUT /withdraws/1.json
  def update
    respond_to do |format|
      if @withdraw.update(withdraw_params)
        format.html { redirect_to @withdraw, notice: 'Withdraw was successfully updated.' }
        format.json { render :show, status: :ok, location: @withdraw }
      else
        format.html { render :edit }
        format.json { render json: @withdraw.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /withdraws/1
  # DELETE /withdraws/1.json
  def destroy
    @withdraw.destroy
    respond_to do |format|
      format.html { redirect_to withdraws_url, notice: 'Withdraw was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_withdraw
      @withdraw = Withdraw.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def withdraw_params
      params.require(:withdraw).permit(:name, :user_id, :is_payed, :amount)
    end
end
