require "./lib/tokens/version"

Gem::Specification.new do |s|
  s.name        = "tokens"
  s.version     = Tokens::Version::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nando Vieira"]
  s.email       = ["fnando.vieira@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/tokens"
  s.summary     = "Generate named tokens on your ActiveRecord models."
  s.description = s.summary

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rails"
  s.add_development_dependency "rake"
  s.add_development_dependency "minitest-utils"
  s.add_development_dependency "mocha"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "pry-meta"
  s.add_development_dependency "codeclimate-test-reporter"
end
