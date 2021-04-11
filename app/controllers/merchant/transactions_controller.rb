# frozen_string_literal: true

class Merchant::TransactionsController < MerchantBaseController
  def index
    @pagy, @transactions = pagy(Transaction.includes(:sender, :receiver).where('sender_id = ? OR receiver_id = ?',
                                                                               current_user.id, current_user.id).order(created_at: :desc))
  end

  def transaction_detail
    @transaction = Transaction.find_by(ref_id: params[:id])
    @card = @transaction&.card
    @sender = @transaction.sender
  end
end
