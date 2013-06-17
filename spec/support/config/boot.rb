ENV["BUNDLE_GEMFILE"] = ENV.fetch("BUNDLE_GEMFILE") {
  File.dirname(__FILE__) + "/../../../Gemfile"
}

require "bundler/setup"
require "rails/all"
Bundler.require(:default)

module Tokens
  class Application < Rails::Application
    config.root = File.dirname(__FILE__) + "/.."
    config.active_support.deprecation = :log
    config.eager_load = true
  end
end

Tokens::Application.initialize!
