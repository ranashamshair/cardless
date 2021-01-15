class AdminBaseController < ActionController::Base
    layout 'admin'
    include Pagy::Backend
    before_action :check_admin
    before_action :authenticate_user!

    def check_admin
        if !current_user.admin?
            redirect_to root_path
        end
    end
end
