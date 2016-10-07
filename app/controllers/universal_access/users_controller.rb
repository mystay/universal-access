require_dependency "universal_access/application_controller"

module UniversalAccess
  class UsersController < ApplicationController

    def autocomplete
      @users = Universal::Configuration.class_name_user.classify.constantize.all
      if Universal::Configuration.user_scoped
        @users = @users.scoped_to(universal_scope)
      end
      if !params[:term].blank?
        @users = @users.full_text_search(params[:term], match: :all)
      end
      json = @users.map{|c| {label: "#{c.name} - #{c.email}", value: c.id.to_s}}
      render json: json.to_json
    end
    
  end
end