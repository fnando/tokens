require "spec_helper"

describe Tokens do
  before do
    User.delete_all
    Post.delete_all

    @user = User.create(name: "Homer")
    @another_user = User.create(name: "Bart")
    @post = Post.create(title: "How to make donuts")
    @expire = 3.days.from_now
  end

  it "has tokens association" do
    expect { @user.tokens }.to_not raise_error
  end

  it "removes all expired tokens" do
    expect {
      %w(uid activation_code reset_password_code).each do |name|
        @user.add_token(name, :expires_at => 3.days.ago)
      end
    }.to change(Token, :count).by(3)

    expect(Token.clean).to eql(3)
  end

  it "generates token without saving it" do
    expect {
      User.generate_token(32)
    }.to_not change(Token, :count)
  end

  it "generates token with custom size" do
    expect(User.generate_token(8).size).to eql(8)
  end

  it "sets alias for token method" do
    token = @user.add_token(:uid)
    expect(token.to_s).to eql(token.token)
  end

  it "finds user by token" do
    token = @user.add_token(:uid)
    expect(User.find_by_token(:uid, token.to_s)).to eql(@user)
  end

  it "returns user by its valid token without expiration time" do
    token = @user.add_token(:uid)
    expect(User.find_by_valid_token(:uid, token.to_s)).to eql(@user)
  end

  it "returns user by its valid token with expiration time" do
    token = @user.add_token(:uid, :expires_at => @expire)
    expect(User.find_by_valid_token(:uid, token.to_s)).to eql(@user)
  end

  it "finds token using class method with one argument (hash only)" do
    token = @user.add_token(:uid)
    expect(User.find_token(:name => :uid, :token => token.to_s)).to eql(token)
  end

  it "doesn't conflict with other models" do
    user_token = @user.add_token(:uid)
    post_token = @post.add_token(:uid)

    expect(User.find_token(post_token.to_s)).to be_nil
    User.find_token(name: :uid)
  end

  it "to_s should return hash" do
    token = @user.add_token(:uid)
    expect(token.to_s).to eql(token.to_s)
  end

  describe Token do
    it "is created" do
      expect { @user.add_token(:uid) }.to change(Token, :count)
    end

    it "is created for different users" do
      expect(@user.add_token(:uid)).to be_valid
      expect(@another_user.add_token(:uid)).to be_valid
    end

    it "is created with expiration date" do
      expect(@user.add_token(:uid, expires_at: @expire).expires_at).to eql(@expire)
    end

    it "serializes data" do
      token = @user.add_token(:uid, data: {name: "John Doe"})
      token.reload

      expect(token.data).to include("name" => "John Doe")
    end

    it "returns empty hash as serialized data" do
      expect(Token.new.data).to eql({})
    end

    it "is created with custom size" do
      expect(@user.add_token(:uid, :size => 6).to_s.size).to eql(6)
    end

    it "finds token by its name" do
      token = @user.add_token(:uid)
      expect(@user.find_token_by_name(:uid)).to eql(token)
    end

    it "returns nil nil when no token is found" do
      expect(@user.find_token(:uid, "abcdef")).to be_nil
      expect(@user.find_token_by_name(:uid)).to be_nil
    end

    it "is a valid token" do
      token = @user.add_token(:uid)
      expect(@user.valid_token?(:uid, token.to_s)).to be_true
    end

    it "isn't a valid token" do
      expect(@user.valid_token?(:uid, "invalid")).to be_false
    end

    it "finds token by its name and hash" do
      token = @user.add_token(:uid)
      expect(@user.find_token(:uid, token.to_s)).to eql(token)
    end

    it "isn't expired when have no expiration date" do
      expect(@user.add_token(:uid)).not_to be_expired
    end

    it "isn't expired when have a future expiration date" do
      expect(@user.add_token(:uid, expires_at: 3.days.from_now)).not_to be_expired
    end

    it "is expired" do
      expect(@user.add_token(:uid, :expires_at => 3.days.ago)).to be_expired
    end

    it "removes token" do
      @user.add_token(:uid)
      expect(@user.remove_token(:uid)).to be_true
    end

    it "doesn't remove other users tokens" do
      @user.add_token(:uid)
      @another_user.add_token(:uid)

      @user.remove_token(:uid)

      expect(@user.find_token_by_name(:uid)).to be_nil
      expect(@another_user.find_token_by_name(:uid)).to be_an_instance_of(Token)
    end

    it "isn't duplicated" do
      @user.add_token(:uid)
      @user.add_token(:uid)

      expect(@user.tokens.where(name: "uid").count).to eql(1)
    end
  end
end
