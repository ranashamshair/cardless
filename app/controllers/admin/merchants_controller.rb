class Admin::MerchantsController < AdminBaseController
  

  def index
    @pagy, @merchants = pagy(User.merchant)
  end
end
