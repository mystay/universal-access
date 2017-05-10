module UniversalAccess
  module Concerns
    module GroupAccess
      extend ActiveSupport::Concern

      included do
        field :_ugid, as: :universal_user_group_ids, type: Array
        field :_ugf, as: :universal_user_group_functions, type: Hash

        def set_user_group!(user_group, yes_no=true, scope=nil)
          if ::UniversalAccess::Configuration.scoped_user_groups and !scope.nil?
            user_group = ::UniversalAccess::UserGroup.where(scope: scope).find(user_group)||::UniversalAccess::UserGroup.find_by(scope: scope, code: user_group) if user_group.class == String
          else
            user_group = ::UniversalAccess::UserGroup.find(user_group)||::UniversalAccess::UserGroup.find_by(code: user_group) if user_group.class == String
          end
          if !user_group.nil?
            if self._ugid.nil?
              self.update(_ugid: [user_group.id.to_s])
            elsif yes_no
              self.push(_ugid: user_group.id.to_s) if !self.universal_user_groups.include?(user_group)
            else !yes_no
              self.pull(_ugid: user_group.id.to_s)
            end
          end
          self.update_user_group_functions!
        end

        def update_user_group_functions!
          all_functions = {}
          user_groups = ::UniversalAccess::UserGroup.in(id: self._ugid)
          if ::UniversalAccess::Configuration.scoped_user_groups
            user_groups.each do |group|
              if !group.functions.nil?
                group.functions.each do |function|
                  category = function[0]
                  all_functions[category] ||= {}
                  existing_category = all_functions[category][group.scope_id.to_s] || all_functions[category][group.scope_id.to_s] = []
                  function[1].each do |func|
                    existing_category.push(func) if !existing_category.include?(func)
                  end
                end
              end
            end
          else #groups are not scoped
            user_groups.each do |group|
              if !group.functions.nil?
                group.functions.each do |function|
                  category = function[0]
                  existing_category = all_functions[category] || all_functions[category] = []
                  function[1].each do |func|
                    existing_category.push(func) if !existing_category.include?(func)
                  end
                end
              end
            end
          end
          self.set(_ugf: all_functions)
        end

        #find the groups that this user belongs to
        def universal_user_groups(scope=nil)
          return [] if self._ugid.nil? or self._ugid.empty?
          if ::UniversalAccess::Configuration.scoped_user_groups
            @user_groups ||= ::UniversalAccess::UserGroup.in(id: self._ugid, scope: scope).cache
          else
            @user_groups ||= ::UniversalAccess::UserGroup.in(id: self._ugid).cache
          end
        end

        def universal_user_group_codes
          self.universal_user_groups.map(&:code)
        end

        def user_group_function_categories
          return self._ugf.map{|f| f.to_a[0]} if !self._ugf.nil?
          []
        end

        #check if a user has this function
        def has?(category, function=nil, scope=nil)
          return false if self._ugf.nil? or self._ugf[category.to_s].nil?
          if ::UniversalAccess::Configuration.scoped_user_groups
            raise 'Nil Scope. A scope model must be passed to has? method in UniversalAccess::Concerns::GroupAccess' if scope.nil?
            return (self._ugf[category.to_s].class != Array and !self._ugf[category.to_s][scope.id.to_s].nil? and (function.nil? or self._ugf[category.to_s][scope.id.to_s].include?(function.to_s)))
          else
            return (!self._ugf[category.to_s].nil? and (function.nil? or self._ugf[category.to_s].include?(function.to_s)))
          end
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