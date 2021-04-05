# frozen_string_literal: true

class Merchant::AccountsController < MerchantBaseController
  before_action :set_wallet

  def show
    if @wallet.reserve?
      @reserve_wallet = @wallet
      @wallet = @wallet.user.wallets.primary.first
    else
      @reserve_wallet = @wallet.user.wallets.reserve.first
    end
    reserve_release = current_user.reserve_schedules.where('DATE(release_date) = ?', Date.today)
    @reserve_release_amount = reserve_release.pluck(:amount).sum if reserve_release.present?
  end

  def account_transactions
    @pagy, @transactions = pagy(Transaction.where('sender_wallet_id = ? OR receiver_wallet_id = ?', @wallet.id,
                                                  @wallet.id).order(created_at: :desc))
  end

  private

  def set_wallet
    @wallet = Wallet.friendly.find(params[:id])
  end
end
