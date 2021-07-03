# frozen_string_literal: true

class VisitorsController < ApplicationController
  # skip_before_action :check_merchant

  def index; end

  def about
    distro = Wallet.distro.first.id
    @revenue = Transaction.where(receiver_wallet_id: distro)&.pluck(:amount)
  end

  def pricing; end

  def faq; end

  def terms; end

  def privacy; end

  def contact; end

  def docs ; end

  def marketplace
  end

  def search
  end

  def spinner
  end

end
