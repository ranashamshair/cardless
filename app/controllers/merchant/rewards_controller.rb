class Merchant::RewardsController < MerchantBaseController
  def index
    @pagy, @rewards = pagy(current_user.rewards)
  end
end
