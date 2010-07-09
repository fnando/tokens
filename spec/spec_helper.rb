$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"

require "spec"
require "ruby-debug"
require "active_record"
require "tokens"

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ":memory:")

load('schema.rb')

class Object
  def self.unset_class(*args)
    class_eval do
      args.each do |klass|
        eval(klass) rescue nil
        remove_const(klass) if const_defined?(klass)
      end
    end
  end
end

alias :doing :lambda
