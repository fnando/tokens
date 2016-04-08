require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

ENV["RAILS_ENV"] = "test"

require "bundler/setup"
require "rails"
require "rails/railtie"
require "action_controller/railtie"
require "tokens"

require "minitest/utils"
require "minitest/autorun"

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

module Minitest
  class Test
    setup do
      User.delete_all
      Post.delete_all
      Token.delete_all
    end
  end
end
