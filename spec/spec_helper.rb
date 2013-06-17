ENV["RAILS_ENV"] = "test"

require "bundler/setup"
require "rails"
require "rails/railtie"
require "action_controller/railtie"
require "rspec/rails"
require "tokens"

module Tokens
  class Application < Rails::Application
    config.root = File.dirname(__FILE__) + "/.."
    config.active_support.deprecation = :log
    config.eager_load = true
  end
end

Tokens::Application.initialize!
ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

# Load database schema
begin
  load File.dirname(__FILE__) + "/schema.rb"
rescue Exception => e
  p e
end

require "support/models"

RSpec.configure do |config|
  config.mock_with :rspec
end
