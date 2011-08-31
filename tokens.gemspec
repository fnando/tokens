# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "tokens/version"

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

  s.add_development_dependency "rails"        , "~> 3.1"
  s.add_development_dependency "rake"         , "~> 0.9"
  s.add_development_dependency "rspec-rails"  , "~> 2.6"
  s.add_development_dependency "sqlite3"      , "~> 1.3.4"
  s.add_development_dependency "ruby-debug19"
end
