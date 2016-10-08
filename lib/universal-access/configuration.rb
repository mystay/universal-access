module UniversalAccess
  class Configuration

    cattr_accessor :user_group_collection

    def self.reset
      self.user_group_collection = 'universal_access_user_groups'
    end

  end
end
UniversalAccess::Configuration.reset