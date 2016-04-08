require "test_helper"

class ActiveRecordTest < Minitest::Test
  setup do
    @user = User.create(name: "Homer")
    @another_user = User.create(name: "Bart")
    @post = Post.create(title: "How to make donuts")
    @expire = 3.days.from_now
  end

  test "is created" do
    count = Token.count
    @user.add_token(:uid)

    assert_equal count + 1, Token.count
  end

  test "is created for different users" do
    assert @user.add_token(:uid).valid?
    assert @another_user.add_token(:uid).valid?
  end

  test "is created with expiration date" do
    assert_equal @expire, @user.add_token(:uid, expires_at: @expire).expires_at
  end

  test "serializes data" do
    token = @user.add_token(:uid, data: {name: "John Doe"})
    token.reload

    assert_equal "John Doe", token.data["name"]
  end

  test "returns empty hash as serialized data" do
    assert_equal Hash.new, Token.new.data
  end

  test "is created with custom size" do
    assert_equal 6, @user.add_token(:uid, :size => 6).to_s.size
  end

  test "finds token by its name" do
    token = @user.add_token(:uid)
    assert_equal token, @user.find_token_by_name(:uid)
  end

  test "returns nil nil when no token is found" do
    assert_nil @user.find_token(:uid, "abcdef")
    assert_nil @user.find_token_by_name(:uid)
  end

  test "is a valid token" do
    token = @user.add_token(:uid)
    assert @user.valid_token?(:uid, token.to_s)
  end

  test "isn't a valid token" do
    refute @user.valid_token?(:uid, "invalid")
  end

  test "finds token by its name and hash" do
    token = @user.add_token(:uid)
    assert_equal token, @user.find_token(:uid, token.to_s)
  end

  test "isn't expired when have no expiration date" do
    refute @user.add_token(:uid).expired?
  end

  test "isn't expired when have a future expiration date" do
    refute @user.add_token(:uid, expires_at: 3.days.from_now).expired?
  end

  test "is expired" do
    assert @user.add_token(:uid, :expires_at => 3.days.ago).expired?
  end

  test "removes token" do
    @user.add_token(:uid)
    assert @user.remove_token(:uid)
  end

  test "doesn't remove other users tokens" do
    @user.add_token(:uid)
    @another_user.add_token(:uid)

    @user.remove_token(:uid)

    assert_nil @user.find_token_by_name(:uid)
    assert_kind_of Token, @another_user.find_token_by_name(:uid)
  end

  test "isn't duplicated" do
    @user.add_token(:uid)
    @user.add_token(:uid)

    assert_equal 1, @user.tokens.where(name: "uid").count
  end

  test "returns valid token" do
    token = @user.add_token(:uid)
    assert_equal token, @user.find_valid_token(:uid, token.to_s)
  end

  test "returns nothing for invalid token" do
    token = @user.add_token(:uid)
    assert_nil @user.find_valid_token(:uid, "invalid")
  end

  test "returns nothing for missing token" do
    assert_nil @user.find_valid_token(:uid, "invalid")
  end

  test "returns nothing for expired token" do
    token = @user.add_token(:uid, expires_at: 2.weeks.ago)
    assert_nil @user.find_valid_token(:uid, "invalid")
  end

  test "creates token with provided value" do
    token = @user.add_token(:uid, token: 'abc123')
    assert_equal "abc123", token.to_s
  end
end
