class ApplicationController < ActionController::Base
    before_action :check_merchant

    def check_merchant
        if current_user.present?
            if current_user.admin?
                redirect_to admin_dashboard_index_path
            end
        else
            redirect_to root_path
        end
    end
end
