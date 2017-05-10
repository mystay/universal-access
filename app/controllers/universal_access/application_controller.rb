module UniversalAccess
  class ApplicationController < ::ApplicationController
    helper Universal::Engine::ApplicationHelper
    
    before_filter :enforce_user_access
    
    def enforce_user_access
      render file: "#{Rails.root}/public/404.html", status: 404, layout: false if !universal_access_allowed
    end
    
  end
end
