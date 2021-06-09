class Merchant::AccountTransfersController < MerchantBaseController
  def index
  end

  def new
    @account_transfer = AccountTransfer.new
    @fee = Fee.last.account_transfer
    @balance = current_user.wallets.primary.first.balance
  end

  def create
    receiver = User.merchant.where(email: params[:account_transfer][:receiver_wallet_id]).last
    if receiver != current_user
      if params[:account_transfer][:amount].to_f > 0
        receiver_wallet = receiver.wallets.primary.first
        sender_wallet = current_user.wallets.primary.first
        total_amount = params[:account_transfer][:amount].to_f + Fee.last.account_transfer.to_f
        if total_amount <= sender_wallet.balance.to_f
          # account_transfer
        else
          redirect_back(fallback_location: root_path)
        end
      else
        redirect_back(fallback_location: root_path)
      end
    else
      redirect_back(fallback_location: root_path)
    end
  end

  def check_email
    @user = User.merchant.where(email: params[:account_transfer][:receiver_wallet_id]).last
    @same_user = @user if @user == current_user
  end

  private

  def account_transfer_params
    params.require(:account_transfer).permit(:receiver_wallet_id, :amount, :fee, :reason, :instruction, :sender_wallet_id)
  end
end
