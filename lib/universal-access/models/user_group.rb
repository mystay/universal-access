module UniversalAccess
  module Models
    module UserGroup
      extend ActiveSupport::Concern
      
      included do
        include Mongoid::Document
        
        include Universal::Concerns::Scoped
        
        store_in collection: UniversalAccess::Configuration.user_group_collection

        field :code
        field :name
        field :notes
        field :functions, type: Hash
        field :locked, type: Boolean, default: false

        before_validation :update_relations

        validates_presence_of :code, :name

        default_scope ->{order_by(name: :asc)}
        scope :for_codes, ->(codes){where(:code.in => codes.map{|c| c.to_s})}
    
        after_update :update_user_functions
    
        def users
          Universal::Configuration.class_name_user.classify.constantize.where(_ugid: self.id.to_s)
        end
        
        def update_user_functions
          users = Universal::Configuration.class_name_user.classify.constantize.where(_ugid: self.id.to_s)
          users.map{|u| u.update_user_group_functions!}
        end
        
        private
        def update_relations
          self.code = self.name.parameterize('_') if self.code.blank? and !self.name.blank?
        end
        
      end
      
    end
  end
end