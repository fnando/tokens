require "spec_helper"

# unset models used for testing purposes
Object.unset_class('User')

class User < ActiveRecord::Base
  has_tokens
end

describe "has_tokens" do
  fixtures :users
  
  before(:each) do
    @user = users(:homer)
    @another_user = users(:bart)
    @expire = 3.days.from_now
  end
  
  describe "- token" do
    it "should be created" do
      doing { @user.add_token(:uid) }.should change(Token, :count)
    end
    
    it "should be created for different users" do
      @user.add_token(:uid).should be_valid
      @another_user.add_token(:uid).should be_valid
    end
    
    it "should be created with expiration date" do
      @user.add_token(:uid, :expires_at => @expire).expires_at.should == @expire
    end
    
    it "should be created with additional data" do
      @user.add_token(:uid, :data => 'some value').data.should == 'some value'
    end
    
    it "should be created with custom size" do
      @user.add_token(:uid, :size => 6).hash.size.should == 6
    end
    
    it "should find token by its name" do
      @user.add_token(:uid)
      @user.find_token_by_name(:uid).should be_an_instance_of(Token)
    end
    
    it "should be nil when no token is found" do
      @user.find_token('abcdef').should be_nil
      @user.find_token_by_name(:uid).should be_nil
    end
    
    it "should be a valid token" do
      token = @user.add_token(:uid)
      @user.valid_token?(:uid, token.hash).should be_true
    end
    
    it "should not be a valid token" do
      @user.valid_token?(:uid, 'invalid').should be_false
    end
    
    it "should find token by its hash" do
      token = @user.add_token(:uid)
      @user.find_token(token.hash).should be_an_instance_of(Token)
    end
    
    it "should not be expired when have no expiration date" do
      @user.add_token(:uid).should_not be_expired
    end
    
    it "should not be expired when have a future expiration date" do
      @user.add_token(:uid, :expires_at => 3.days.from_now).should_not be_expired
    end
    
    it "should be expired" do
      @user.add_token(:uid, :expires_at => 3.days.ago).should be_expired
    end
    
    it "should remove token" do
      @user.add_token(:uid)
      @user.remove_token(:uid).should > 0
    end
    
    it "should not remove other users tokens" do
      @user.add_token(:uid)
      @another_user.add_token(:uid)
      
      @user.remove_token(:uid)
      
      @user.find_token_by_name(:uid).should be_nil
      @another_user.find_token_by_name(:uid).should be_an_instance_of(Token)
    end
    
    it "should not be duplicated" do
      @user.add_token(:uid)
      @user.add_token(:uid)
      
      @user.tokens.find_all_by_name('uid').size.should == 1
    end
  end
  
  it "should have tokens association" do
    doing { @user.tokens }.should_not raise_error
  end
  
  it "should remove all expired tokens" do
    doing {
      %w(uid activation_code reset_password_code).each do |name|
        @user.add_token(name, :expires_at => 3.days.ago)
      end
    }.should change(Token, :count).by(3)
    
    Token.delete_expired.should == 3
  end
  
  it "should generate token without saving it" do
    doing {
      User.generate_token(Time.now.to_s, 32)
    }.should_not change(Token, :count)
  end
  
  it "should generate token with custom size" do
    User.generate_token(Time.now.to_s, 8).size.should == 8
  end
  
  it "should alias token method" do
    token = @user.add_token(:uid)
    token.hash.should == token.token
  end
end