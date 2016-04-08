require "test_helper"

class TokensTest < Minitest::Test
  setup do
    @user = User.create(name: "Homer")
    @another_user = User.create(name: "Bart")
    @post = Post.create(title: "How to make donuts")
    @expire = 3.days.from_now
  end

  test "has tokens association" do
    @user.tokens
  end

  test "removes all expired tokens" do
    %w(uid activation_code reset_password_code).each do |name|
      @user.add_token(name, :expires_at => 3.days.ago)
    end

    assert_equal 3, Token.clean
  end

  test "generates token without saving it" do
    count = Token.count
    User.generate_token(32)

    assert_equal count, Token.count
  end

  test "generates token with custom size" do
    assert_equal 8, User.generate_token(8).size
  end

  test "sets alias for token method" do
    token = @user.add_token(:uid)
    assert_equal token.token, token.to_s
  end

  test "finds user by token" do
    token = @user.add_token(:uid)
    assert_equal @user, User.find_by_token(:uid, token.to_s)
  end

  test "returns user by its valid token without expiration time" do
    token = @user.add_token(:uid)
    assert_equal @user, User.find_by_valid_token(:uid, token.to_s)
  end

  test "returns user by its valid token with expiration time" do
    token = @user.add_token(:uid, :expires_at => @expire)
    assert_equal @user, User.find_by_valid_token(:uid, token.to_s)
  end

  test "finds token using class method with one argument (hash only)" do
    token = @user.add_token(:uid)
    assert_equal token, User.find_token(:name => :uid, :token => token.to_s)
  end

  test "doesn't conflict with other models" do
    user_token = @user.add_token(:uid)
    post_token = @post.add_token(:uid)

    assert_nil User.find_token(post_token.to_s)
    User.find_token(name: :uid)
  end

  test "to_s should return hash" do
    token = @user.add_token(:uid)
    assert_equal token.to_s, token.to_s
  end
end
