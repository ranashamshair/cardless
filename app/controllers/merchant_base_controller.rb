class MerchantBaseController < ActionController::Base
    layout 'merchant'
    include Pagy::Backend
    before_action :check_merchant
    before_action :authenticate_user!

    def check_merchant
        if !current_user.merchant?
            redirect_to root_path
        end
    end
end
