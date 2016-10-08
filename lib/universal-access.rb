require "universal-access/engine"
require "universal-access/configuration"
Gem.find_files("universal-access/models/*.rb").each { |path| require path }
module UniversalAccess
end
