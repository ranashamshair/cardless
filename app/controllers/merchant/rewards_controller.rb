class Merchant::RewardsController < MerchantBaseController
  before_action :set_reward, only: [:get_reward]
  before_action :check_reward_status, only: [:get_reward]

  def index
    @pagy, @rewards = pagy(current_user.rewards)
  end

  def get_reward
  end

  private

  def set_reward
    @reward = Reward.find(params[:id])
  end

  def check_reward_status
    if @reward.payed
      redirect_to merchant_rewards_path
    end
  end
end
