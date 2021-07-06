class Merchant::RewardsController < MerchantBaseController
  before_action :set_reward, only: [:get_reward, :save_reward]
  before_action :check_reward_status, only: [:get_reward, :save_reward]

  def index
    @reward_amount = Fee.last.reward_amount
    @pagy, @rewards = pagy(current_user.rewards)
  end

  def get_reward
    @reward_amounts = RewardInfo.all
    @reward_data = []
    colors = ["#5D26C1","#59C173"]
    color = "#5D26C1"
    @reward_amounts&.each do |reward|
      @reward_data.push({
        "label" =>  "#{reward.amount}",
        "value" => "#{reward.id}",
        "color" => color,
        "anchor" =>  "Get your reward",
        "question" => "Congratulation you win #{reward.amount}"
        })
        if color == "#5D26C1"
          color = "#59C173"
        else
          color = "#5D26C1"
        end
    end
  end

  def save_reward
    @reward_info = RewardInfo.find_by(id: params[:value])
    return redirect_to merchant_rewards_path, notice: "Invalid data!" if @reward_info.blank? || @reward_info.amount.to_f != params[:amount].to_f
    distro = Wallet.distro.first
    receiver_wallet = @reward.user.wallets.primary.first
    tx = Transaction.new(
      amount: @reward_info.amount,
      net_amount: @reward_info.amount,
      sender_wallet_id: distro.id,
      receiver_wallet_id: receiver_wallet.id,
      sender_id: distro.user.id,
      receiver_id: @reward.user_id,
      action: :transfer,
      main_type: :reward,
      status: :pending,
      ref_id: SecureRandom.hex,
      sender_balance: distro.balance.to_f - @reward_info.amount.to_f,
      receiver_balance: receiver_wallet.balance.to_f + @reward_info.amount.to_f
    )
    if tx.save
      @reward.update(payed: true, payed_at: Time.now)
      tx.update(status: :success)
      distro.update(balance: distro.balance.to_f - @reward_info.amount.to_f)
      receiver_wallet.update(balance: receiver_wallet.balance.to_f + @reward_info.amount.to_f)
    end
    return redirect_to merchant_rewards_path, notice: "You have received reward of #{params[:amount]}"
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
