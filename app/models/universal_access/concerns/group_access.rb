module UniversalAccess
  module Concerns
    module GroupAccess
      extend ActiveSupport::Concern

      included do
        field :_ugid, as: :universal_user_group_ids, type: Array
        field :_ugf, as: :universal_user_group_functions, type: Hash

        def set_user_group!(user_group, yes_no=true)
          user_group = ::UniversalAccess::UserGroup.find(user_group) if user_group.class == String
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
          user_groups.each do |group|
            scope_id = group.scope_id.blank? ? 'all' : group.scope_id.to_s
            if !group.functions.nil?
              group.functions.each do |function|
                category = function[0]
                all_functions[category] ||= {}
                existing_category = all_functions[category][scope_id] || all_functions[category][scope_id] = []
                function[1].each do |func|
                  existing_category.push(func) if !existing_category.include?(func)
                end
              end
            end
          end
          self.set(_ugf: all_functions)
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
          return self._ugf.map{|f| f.to_a[0]} if !self._ugf.nil?
          []
        end
        
        def scoped_universal_user_group_functions(scope)
          return [] if self.universal_user_group_functions.blank? or scope.nil?
          new_ugf = {}
          self._ugf.each do |uu|
            function_group = uu[0]
            uu[1].each do |uuu|
              if uuu[0].to_s == scope.id.to_s
                new_ugf[function_group] ||= []
                new_ugf[function_group] += uuu[1]
                new_ugf[function_group].uniq!
              end
            end
          end
          return new_ugf
        end
        
        def unscoped_user_group_functions
          return nil if self._ugf.nil?
          if @unscoped_user_group_functions.nil?
            new_ugf = {}
            self._ugf.each do |uu|
              function_group = uu[0]
              uu[1].each do |uuu|
                new_ugf[function_group] ||= []
                new_ugf[function_group] += uuu[1]
                new_ugf[function_group].uniq!
              end
            end
            @unscoped_user_group_functions = new_ugf
          end
          return @unscoped_user_group_functions
        end

        #check if a user has this function
        def has?(category, function=nil, scope='all')
          return false if self._ugf.nil?
          if scope.to_s=='all'
            return (!self.unscoped_user_group_functions.nil? && !self.unscoped_user_group_functions[category.to_s].nil? and (function.nil? or self.unscoped_user_group_functions[category.to_s].include?(function.to_s)))
          else
            return (!self._ugf[category.to_s].nil? and !self._ugf[category.to_s][scope.id.to_s].nil? and (function.nil? or self._ugf[category.to_s][scope.id.to_s].include?(function.to_s)))
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