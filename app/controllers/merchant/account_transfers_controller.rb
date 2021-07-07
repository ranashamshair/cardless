class Merchant::AccountTransfersController < MerchantBaseController
  def index
    @pagy,@account_transfers = pagy(AccountTransfer.where('sender_id = ? OR receiver_id = ?', current_user.id, current_user.id).order(created_at: :desc))
  end

  def new
    @account_transfer = AccountTransfer.new
    @fee = Fee.last.account_transfer
    @balance = current_user.wallets.primary.first.balance
  end

  def create
    receiver = User.merchant.where(email: params[:account_transfer][:receiver_wallet_id]).last
    if receiver.present? && receiver != current_user
      if params[:account_transfer][:amount].to_f > 0
        fee = Fee.last.account_transfer.to_f
        receiver_wallet = receiver.wallets.primary.first
        sender_wallet = current_user.wallets.primary.first
        total_amount = params[:account_transfer][:amount].to_f + fee.to_f
        distro_wallet = Wallet.distro.first
        if total_amount <= sender_wallet.balance.to_f
          transfer_tx = Transaction.new(
            amount: total_amount,
            receiver_wallet_id: receiver_wallet.id,
            receiver_id: receiver_wallet.user.id,
            sender_id: current_user.id,
            sender_wallet_id: sender_wallet.id,
            receiver_balance: receiver_wallet.balance.to_f + params[:account_transfer][:amount].to_f,
            sender_balance: sender_wallet.balance.to_f - total_amount.to_f,
            main_type: 7,
            action: 0,
            ref_id: SecureRandom.hex,
            status: 1,
            fee: fee,
            total_fee: fee,
            net_amount: total_amount.to_f - fee.to_f
          )
          fee_tx = Transaction.new(
            amount: fee,
            receiver_wallet_id: distro_wallet.id,
            receiver_id: distro_wallet.user.id,
            sender_id: current_user.id,
            sender_wallet_id: sender_wallet.id,
            net_amount: fee,
            ref_id: SecureRandom.hex,
            main_type: 8,
            status: 1,
            action: 0
          )
          account_transfer = AccountTransfer.new(
            amount: params[:account_transfer][:amount],
            fee: fee,
            receiver_wallet_id: receiver_wallet.id,
            receiver_id: receiver_wallet.user.id,
            sender_id: current_user.id,
            sender_wallet_id: sender_wallet.id,
            instruction: params[:account_transfer][:instruction],
            reason: params[:account_transfer][:reason],
            ref_id: "AC-#{SecureRandom.hex.first(6)}"
          )
          if account_transfer.save
            transfer_tx.save
            fee_tx.save
            account_transfer.update(tx_id: transfer_tx.id)
            receiver_wallet.update(balance: receiver_wallet.balance.to_f + params[:account_transfer][:amount].to_f)
            sender_wallet.update(balance: sender_wallet.balance.to_f - total_amount.to_f)
            distro_wallet.update(balance: distro_wallet.balance.to_f + fee.to_f)
            redirect_back(fallback_location: root_path, notice: "successfully transfered amount")
          else
            redirect_back(fallback_location: root_path, notice: "something went wrong")
          end
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
