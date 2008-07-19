require 'has_tokens'
ActiveRecord::Base.send(:include, SimplesIdeias::Acts::Tokens)

require File.dirname(__FILE__) + '/lib/token'
require File.dirname(__FILE__) + '/lib/string_ext'

