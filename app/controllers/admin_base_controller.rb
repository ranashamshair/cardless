class AdminBaseController < ActionController::Base
    layout 'admin'
    include Pagy::Backend
end
