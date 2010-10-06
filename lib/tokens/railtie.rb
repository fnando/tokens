module Tokens
  class Railtie < Rails::Railtie
    generators do
      require "tokens/generator"
    end

    initializer "tokens.initializer" do |app|
      ::ActiveRecord::Base.send :include, ActiveRecord
    end
  end
end
