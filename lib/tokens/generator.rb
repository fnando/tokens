require "rails/generators/base"

module Tokens
  class InstallGenerator < ::Rails::Generators::Base
    source_root File.dirname(__FILE__) + "/../../templates"

    def copy_migrations
      stamp = proc {|time| time.utc.strftime("%Y%m%d%H%M%S")}
      copy_file "tokens.rb", "db/migrate/#{stamp[Time.now]}_create_tokens.rb"
    end
  end
end
