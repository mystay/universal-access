module UniversalAccess
  module Concerns
    module GroupAccess
      extend ActiveSupport::Concern

      included do
        field :_ugid, as: :user_group_ids, type: Array
        field :_ugf, as: :user_group_functions, type: Hash

        def set_user_group!(user_group, yes_no=true)
          user_group = ::UniversalAccess::UserGroup.find(user_group) if user_group.class == String
          if !user_group.nil?
            if self._ugid.nil?
              self.update(_ugid: [user_group.id.to_s])
            elsif yes_no
              self.push(_ugid: user_group.id.to_s) if !self.universal_user_groups.include?(user_group)
            else !yes_no
              logger.debug "PULL"
              self.pull(_ugid: user_group.id.to_s)
            end
          end
          self.update_user_group_functions!
        end

        def update_user_group_functions!
          fun = {}
          user_groups = ::UniversalAccess::UserGroup.in(id: self._ugid)
          user_groups.each do |group|
            if !group.functions.nil?
              group.functions.each do |function|
                category = function[0]
                existing_category = fun[category] || fun[category] = []
                function[1].each do |func|
                  existing_category.push(func) if !existing_category.include?(func)
                end
              end
            end
          end
          self.update(user_group_functions: fun)
        end

        #find the groups that this user belongs to
        def universal_user_groups
          return [] if self._ugid.nil? or self._ugid.empty?
          @user_groups ||= ::UniversalAccess::UserGroup.in(id: self._ugid).cache
        end

        def universal_user_group_codes
          self.universal_user_groups.map(&:code)
        end

        def user_group_function_categories
          return self.user_group_functions.map{|f| f.to_a[0]} if !self.user_group_functions.nil?
          []
        end

        #check if a user has this function
        def has?(category, function)
          !self.user_group_functions.nil? and
            (!self.user_group_functions[category.to_s].nil? and self.user_group_functions[category.to_s].include?(function.to_s))
        end

        #check if the user is in the group
        def in_universal_group?(group_codes=[])
          group_codes = [group_codes.to_s] if group_codes.class == String or group_codes.class == Symbol
          group_codes = group_codes.map{|c| c.to_s}
          groups = self.universal_user_groups
          groups = groups.select{|g| group_codes.include?(g.code)}
          return groups.any?
        end

      end
    end
  end
end