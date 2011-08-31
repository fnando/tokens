ENV["RAILS_ENV"] = "test"
require "tokens"
require File.dirname(__FILE__) + "/support/config/boot"
require "rspec/rails"

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
