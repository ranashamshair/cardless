# frozen_string_literal: true

class Merchant::ReserveSchedulesController < MerchantBaseController
  def index
    @pagy, @reserve_schedules = pagy(current_user.reserve_schedules.includes(:main_tx))
  end
end
