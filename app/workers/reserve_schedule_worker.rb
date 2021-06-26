# frozen_string_literal: true

class ReserveScheduleWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default', :retry => 3, backtrace: 8
  def perform(*_args)
    ReserveSchedule.where(reserve_status: :pending).try(:each) do |reserve_schedule|
      if reserve_schedule.release_date >= DateTime.now
        tx = Transaction.new(
          amount: reserve_schedule.amount,
          net_amount: reserve_schedule.amount,
          sender_wallet_id: reserve_schedule.reserve_tx.receiver_wallet_id,
          receiver_wallet_id: reserve_schedule.reserve_tx.sender_wallet_id,
          action: :transfer,
          main_type: :reserve_return,
          status: :pending,
          ref_id: SecureRandom.hex
        )
        if tx.save
          reserve_schedule.update(reserve_status: :transfered)
          tx.update(status: :success)
          sender_wallet = tx.sender_wallet
          receiver_wallet = tx.receiver_wallet
          sender_wallet.update(balance: sender_wallet.balance.to_f - reserve_schedule.amount.to_f)
          receiver_wallet.update(balance: receiver_wallet.balance.to_f + reserve_schedule.amount.to_f)
        end
      end
    end
  end
end
