require "universal-access/engine"
Gem.find_files("universal-access/models/*.rb").each { |path| require path }
module UniversalAccess
end
