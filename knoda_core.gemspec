$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "knoda_core/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "knoda_core"
  s.version     = KnodaCore::VERSION
  s.authors     = ["Adam England"]
  s.email       = ["aengland@knoda.com"]
  s.homepage    = "http://www.knoda.com"
  s.summary     = "Core Engine for knoda projects"
  s.description = "Core Engine for knoda projects"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]
  s.add_dependency "rails", "~> 4.0.0"
  s.add_dependency 'pg', '0.17.1'
  s.add_dependency "bitly", '0.9.0'
  s.add_dependency 'devise', '3.0.0.rc'
  s.add_dependency 'paperclip', '3.4.2'
  s.add_dependency 'aws-sdk'  
  s.add_dependency 'authority', '2.6.0'
  s.add_dependency 'twilio-ruby'


  s.add_development_dependency "sqlite3"
end
