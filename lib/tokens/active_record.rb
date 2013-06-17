module Tokens
  module ActiveRecord
    def self.included(base)
      base.class_eval { extend  ClassMethods }
    end

    module ClassMethods
      # Set up model for using tokens.
      #
      #   class User < ActiveRecord::Base
      #     tokenizable
      #   end
      #
      def tokenizable
        has_many :tokens, as: "tokenizable", dependent: :destroy
        include InstanceMethods
      end

      # Generate token with specified length.
      #
      #   User.generate_token(10)
      #
      def generate_token(size)
        validity = Proc.new {|token| Token.where(:token => token).first.nil?}

        begin
          token = SecureRandom.hex(size)[0, size]
          token = token.encode("UTF-8")
        end while validity[token] == false

        token
      end

      # Find a token
      #
      #   User.find_token(:activation, "abcdefg")
      #   User.find_token(name: activation, token: "abcdefg")
      #   User.find_token(name: activation, token: "abcdefg", tokenizable_id: 1)
      #
      def find_token(*args)
        if args.first.kind_of?(Hash)
          options = args.first
        else
          options = {
            name: args.first,
            token: args.last
          }
        end

        options.merge!(name: options[:name].to_s, tokenizable_type: self.name)
        Token.where(options).includes(:tokenizable).first
      end

      # Find object by token.
      #
      #   User.find_by_token(:activation, "abcdefg")
      #
      def find_by_token(name, hash)
        token = find_token(name: name.to_s, token: hash)
        return unless token
        token.tokenizable
      end

      # Find object by valid token (same name, same hash, not expired).
      #
      #   User.find_by_valid_token(:activation, "abcdefg")
      #
      def find_by_valid_token(name, hash)
        token = find_token(name: name.to_s, token: hash)
        return if !token || token.expired?
        token.tokenizable
      end
    end

    module InstanceMethods
      # Verify if given token is valid.
      #
      #   @user.valid_token?(:active, "abcdefg")
      #
      def valid_token?(name, hash)
        self.tokens.where(name: name.to_s, token: hash.to_s).first != nil
      end

      # Find a token.
      #
      #   @user.find_token(:activation, "abcdefg")
      #
      def find_token(name, token)
        self.class.find_token(
          tokenizable_id: self.id,
          name: name.to_s,
          token: token
        )
      end

      # Find token by its name.
      def find_token_by_name(name)
        self.tokens.where(name: name.to_s).first
      end

      # Remove token.
      #
      #   @user.remove_token(:activate)
      #
      def remove_token(name)
        return if new_record?
        token = find_token_by_name(name)
        token && token.destroy
      end

      # Add a new token.
      #
      #   @user.add_token(:api_key, expires_at: nil)
      #   @user.add_token(:api_key, size: 20)
      #   @user.add_token(:api_key, data: {when: Time.now})
      #
      def add_token(name, options={})
        options.reverse_merge!({
          expires_at: 2.days.from_now,
          size: 12,
          data: nil
        })

        remove_token(name)
        attrs = {
          name: name.to_s,
          token: self.class.generate_token(options[:size]),
          expires_at: options[:expires_at],
          data: options[:data]
        }

        self.tokens.create!(attrs)
      end
    end
  end
end
