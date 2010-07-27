require "rspec"
require "active_record"
require "tokens"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

load("schema.rb")

RSpec.configure do |c|
  c.color_enabled = true
end
