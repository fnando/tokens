require "spec_helper"

describe Tokens do
  before do
    User.delete_all
    Post.delete_all

    @user = User.create(:name => "Homer")
    @another_user = User.create(:name => "Bart")
    @post = Post.create(:title => "How to make donuts")
    @expire = 3.days.from_now
  end

  it "should have tokens association" do
    expect { @user.tokens }.to_not raise_error
  end

  it "should remove all expired tokens" do
    expect {
      %w(uid activation_code reset_password_code).each do |name|
        @user.add_token(name, :expires_at => 3.days.ago)
      end
    }.to change(Token, :count).by(3)

    Token.clean.should == 3
  end

  it "should generate token without saving it" do
    expect {
      User.generate_token(32)
    }.to_not change(Token, :count)
  end

  it "should generate token with custom size" do
    User.generate_token(8).size.should == 8
  end

  it "should alias token method" do
    token = @user.add_token(:uid)
    token.hash.should == token.token
  end

  it "should find user by token" do
    token = @user.add_token(:uid)
    User.find_by_token(:uid, token.hash).should == @user
  end

  it "should return user by its valid token without expiration time" do
    token = @user.add_token(:uid)
    User.find_by_valid_token(:uid, token.hash).should == @user
  end

  it "should return user by its valid token with expiration time" do
    token = @user.add_token(:uid, :expires_at => @expire)
    User.find_by_valid_token(:uid, token.hash).should == @user
  end

  it "should find token using class method with one argument (hash only)" do
    token = @user.add_token(:uid)
    User.find_token(:name => :uid, :token => token.hash).should == token
  end

  it "should not conflict with other models" do
    user_token = @user.add_token(:uid)
    post_token = @post.add_token(:uid)

    User.find_token(post_token.to_s).should == nil
    User.find_token(:name => :uid)
  end

  it "to_s should return hash" do
    token = @user.add_token(:uid)
    token.to_s.should == token.hash
  end

  describe Token do
    it "should be created" do
      expect { @user.add_token(:uid) }.to change(Token, :count)
    end

    it "should be created for different users" do
      @user.add_token(:uid).should be_valid
      @another_user.add_token(:uid).should be_valid
    end

    it "should be created with expiration date" do
      @user.add_token(:uid, :expires_at => @expire).expires_at.should == @expire
    end

    it "should be created with additional data" do
      @user.add_token(:uid, :data => "some value").data.should == "some value"
    end

    it "should serialize data" do
      token = @user.add_token(:uid, :data => {:name => "John Doe"})
      token.reload
      token.data.should == {:name => "John Doe"}
    end

    it "should be created with custom size" do
      @user.add_token(:uid, :size => 6).hash.size.should == 6
    end

    it "should find token by its name" do
      token = @user.add_token(:uid)
      @user.find_token_by_name(:uid).should == token
    end

    it "should be nil when no token is found" do
      @user.find_token(:uid, "abcdef").should be_nil
      @user.find_token_by_name(:uid).should be_nil
    end

    it "should be a valid token" do
      token = @user.add_token(:uid)
      @user.valid_token?(:uid, token.hash).should be_true
    end

    it "should not be a valid token" do
      @user.valid_token?(:uid, "invalid").should be_false
    end

    it "should find token by its name and hash" do
      token = @user.add_token(:uid)
      @user.find_token(:uid, token.hash).should == token
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
      @user.remove_token(:uid).should be_true
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

      @user.tokens.find_all_by_name("uid").size.should == 1
    end
  end
end
