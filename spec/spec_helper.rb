ENV["RAILS_ENV"] = "test"
require "tokens"
require File.dirname(__FILE__) + "/support/config/boot"
require "rspec/rails"

# Load database schema
load File.dirname(__FILE__) + "/schema.rb"

require "support/models"

RSpec.configure do |config|
  config.mock_with :rspec
end
