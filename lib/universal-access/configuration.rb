module UniversalAccess
  class Configuration

    cattr_accessor :user_group_collection, :scoped_user_groups

    def self.reset
      self.user_group_collection = 'universal_access_user_groups'
      self.scoped_user_groups = false
    end

  end
end
UniversalAccess::Configuration.reset