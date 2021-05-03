class Merchant::AccountTransfersController < MerchantBaseController
  def index
  end

  def new
    @account_transfer = AccountTransfer.new
    @fee = Fee.last.account_transfer
    @balance = current_user.wallets.primary.first.balance
  end

  def create
  end

  def check_email
    @user = User.merchant.where(email: params[:account_transfer][:receiver_wallet_id]).last
    @same_user = @user if @user == current_user
  end
end
