require "rspec/core/rake_task"
require "./lib/tokens/version"

begin
  require "jeweler"

  JEWEL = Jeweler::Tasks.new do |gem|
    gem.name = "tokens"
    gem.email = "fnando.vieira@gmail.com"
    gem.homepage = "http://github.com/fnando/tokens"
    gem.authors = ["Nando Vieira"]
    gem.version = Tokens::Version::STRING
    gem.summary = "Generate named tokens on your ActiveRecord models."
    gem.files =  FileList["{Rakefile,README.rdoc,Gemfile,Gemfile.lock,tokens.gemspec}", "{lib,spec,templates}/**/*"]
  end

  Jeweler::GemcutterTasks.new
rescue LoadError => e
  puts "[JEWELER] You can't build a gem until you install jeweler with `gem install jeweler`"
end

RSpec::Core::RakeTask.new do |t|
  t.ruby_opts = %[ -Ilib -Ispec ]
end
