require "rails/railtie"

module Tokens
  class Railtie < Rails::Railtie
    generators do
      require "tokens/generator"
    end
  end
end
