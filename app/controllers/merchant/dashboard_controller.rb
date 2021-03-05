class Merchant::DashboardController < MerchantBaseController
  def index
  end

  def fee_structure
    @fee = Fee.last
  end
end
