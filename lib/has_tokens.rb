require "digest/sha1"

module SimplesIdeias
  module Acts #:nodoc:
    module Tokens #:nodoc:
      def self.included(base)
        base.extend ClassMethods
      end
      
      module ClassMethods
        def has_tokens
          write_inheritable_attribute(:tokenize_me_options, {
            :token_type => ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
          })
          
          class_inheritable_reader :tokenize_me_options
          
          has_many :tokens, :as => :tokenizable, :dependent => :destroy
          include SimplesIdeias::Acts::Tokens::InstanceMethods
        end
        
        def generate_token(seed, size)
          validity = Proc.new { |token| Token.find(:first, :conditions => {:token => token}).nil? }
          
          begin
            seed = Digest::SHA1.hexdigest(seed)
            token = CGI::Session.generate_unique_id(seed).first(size)
          end while !validity.call(token)
          
          token
        end
        
        def find_by_token(name, code)
          token = Token.find(:first, :conditions => {
            :tokenizable_type => tokenize_me_options[:token_type],
            :name => name.to_s,
            :token => code
          })
          
          return nil unless token
          
          find(:first, :conditions => {:id => token.tokenizable_id})
        end
      end
      
      module InstanceMethods
        def valid_token?(name, token)
          t = find_token_by_name(name)
          return false unless t
          return false if t.expires_at < Time.now
          return false unless t.token == token
          return true
        end
        
        def remove_token(name)
          Token.delete_all([
            "tokenizable_id = ? AND tokenizable_type = ? AND name = ?", 
            self.id, 
            self.class.tokenize_me_options[:token_type], 
            name.to_s
          ])
        end
        
        def add_token(name, options={})
          options = {
            :expires_at => 2.days.from_now,
            :size => 12,
            :data => nil
          }.merge(options)
          
          remove_token(name)
          
          seed = "--#{self.id}--#{self.object_id}--#{Time.now}--"
          
          self.tokens.create(
            :name => name.to_s,
            :token => self.class.generate_token(seed, options[:size]),
            :expires_at => options[:expires_at],
            :data => options[:data]
          )
        end
        
        def find_token_by_name(name)
          self.tokens.find_by_name(name.to_s)
        end
        
        def find_token(token)
          self.tokens.find(:first, :conditions => {:token => token.to_s})
        end
      end
    end
  end
end