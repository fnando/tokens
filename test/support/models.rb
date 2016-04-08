class User < ActiveRecord::Base
  tokenizable
end

class Post < ActiveRecord::Base
  tokenizable
end
