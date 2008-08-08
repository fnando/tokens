require "digest/sha1"

class String
  def to_sha1
    Digest::SHA1.hexdigest(self.dup)
  end
end