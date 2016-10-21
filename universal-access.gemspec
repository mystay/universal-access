$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "universal-access/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "universal-access"
  s.version     = UniversalAccess::VERSION
  s.authors     = ["Ben Petro"]
  s.email       = ["ben@bthree.com.au"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of UniversalAccess."
  s.description = "TODO: Description of UniversalAccess."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'rails'
  s.add_dependency 'mongoid'
  s.add_dependency 'haml'
  s.add_dependency 'universal'

end
