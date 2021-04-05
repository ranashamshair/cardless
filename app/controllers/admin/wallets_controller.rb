# frozen_string_literal: true

class Admin::WalletsController < AdminBaseController
  def index
    @wallets = Wallet.where(user_id: params[:merchant_id])
  end
end
