require "digest/sha1"

module SimplesIdeias
  module Acts #:nodoc:
    module Tokens #:nodoc:
      def self.included(base)
        base.extend ClassMethods
      end
      
      module ClassMethods
        def has_tokens
          write_inheritable_attribute(:has_tokens_options, {
            :token_type => ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
          })
          
          class_inheritable_reader :has_tokens_options
          
          has_many :tokens, :as => :tokenizable, :dependent => :destroy
          include SimplesIdeias::Acts::Tokens::InstanceMethods
        end
        
        def generate_token(seed, size)
          validity = Proc.new { |token| Token.find(:first, :conditions => {:token => token}).nil? }
          
          begin
            seed = Digest::SHA1.hexdigest(seed)
            token = Digest::SHA1.hexdigest(seed)[0, size]
          end while !validity.call(token)
          
          token
        end
        
        # Find a token
        # User.find_token(:activation, 'abcdefg')
        # User.find_token(:name => activation, :token => 'abcdefg')
        # User.find_token(:name => activation, :token => 'abcdefg', :tokenizable_id => 1)
        def find_token(*args)
          unless (options = args.first).is_a?(Hash)
            options = {:name => args.first, :token => args.last.to_s}
          end
          
          options[:name] = options[:name].to_s
          options.merge!({:tokenizable_type => has_tokens_options[:token_type]})
          Token.find(:first, :conditions => options)
        end
        
        # Find object by token
        # User.find_by_token(:activation, 'abcdefg')
        def find_by_token(name, token)
          t = find_token(:name => name.to_s, :token => token)
          return nil unless t
          t.tokenizable
        end
        
        # Find object by valid token (same name, same hash, not expired)
        # User.find_by_valid_token(:activation, 'abcdefg')
        def find_by_valid_token(name, token)
          t = find_token(:name => name.to_s, :token => token)
          return nil unless t && !t.expired? && t.hash == token
          t.tokenizable
        end
      end
      
      module InstanceMethods
        # Object has a valid token (same name, same hash, not expired)
        # @user.valid_token?(:activation, 'abcdefg')
        def valid_token?(name, token)
          t = find_token_by_name(name)
          !!(t && !t.expired? && t.hash == token)
        end
        
        def remove_token(name)
          Token.delete_all([
            "tokenizable_id = ? AND tokenizable_type = ? AND name = ?", 
            self.id, 
            self.class.has_tokens_options[:token_type], 
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
        
        # Find a token
        # @user.find_token(:activation, 'abcdefg')
        def find_token(name, token)
          self.class.find_token(:tokenizable_id => self.id, :name => name.to_s, :token => token)
        end
      end
    end
  end
end