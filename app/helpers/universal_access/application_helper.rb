module UniversalAccess
  module ApplicationHelper
    
    def icon(i)
      return "<i class='fa fa-#{i}'></i>".html_safe
    end
    
  end
end