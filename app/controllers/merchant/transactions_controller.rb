class Merchant::TransactionsController < MerchantBaseController
  def index
    @pagy, @transactions = pagy(Transaction.where("sender_id = ? OR receiver_id = ?", current_user.id, current_user.id).order(created_at: :desc))
  end
end
