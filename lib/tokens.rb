require "active_record"
require "securerandom"

require "tokens/active_record"
require "tokens/token"
require "tokens/version"
require "tokens/railtie" if defined?(Rails)

::ActiveRecord::Base.send :include, Tokens::ActiveRecord
