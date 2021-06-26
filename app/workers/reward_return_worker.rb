# frozen_string_literal: true

class RewardReturnWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default', :retry => 3, backtrace: 8

  def perform(*_args)
    fee = Fee.last
    reward_fee = fee.reward_amount
    reward_percent = fee.reward_percent
    reward_amount = reward_fee * reward_percent/100.0
    Reward.where("payed = ? AND amount >= ? ", false, reward_fee).try(:each) do |reward|

        distro = Wallet.distro.first
        receiver_wallet = reward.user.wallets.primary.first
        tx = Transaction.new(
          amount: reward_amount,
          net_amount: reward_amount,
          sender_wallet_id: distro.id,
          receiver_wallet_id: receiver_wallet.id,
          sender_id: distro.user.id,
          receiver_id: reward.user_id,
          action: :transfer,
          main_type: :reward,
          status: :pending,
          ref_id: SecureRandom.hex
        )
        if tx.save
          reward.update(payed: true, payed_at: Time.now)
          tx.update(status: :success)
          distro.update(balance: distro.balance.to_f - reward_amount)
          receiver_wallet.update(balance: receiver_wallet.balance.to_f + reward_amount.to_f)
        end
      end
  end
end
