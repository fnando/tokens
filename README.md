# Tokens

[![Build Status](https://travis-ci.org/fnando/tokens.png)](https://travis-ci.org/fnando/tokens)

## Usage

### Installation

```bash
gem install tokens
```

### Setting up

Add Tokens to your Gemfile and run `rails generate tokens:install`.
This will create a new migration file. Execute it by running `rake db:migrate`.

Finally, add the macro `tokenizable` to your model and be happy!

```ruby
class User < ActiveRecord::Base
  tokenizable
end

# create a new user; remember that the object need to be saved before creating
# the token because it depends on the id
user = User.create(username: "fnando")

# create token that never expires
user.add_token(:activate)

# uses custom expires_at
user.add_token(:activate, expires_at: 10.days.from_now)

# uses the default size (12 characters)
user.add_token(:activate)

# uses custom size (up to 122)
user.add_token(:activate, size: 20)

# create token with arbitrary data.
user.add_token(:activate, data: {action: "do something"})

# find token by name
user.find_token_by_name(:reset_account)

# find token by hash
user.find_token("ea2f14aeac40")

# check if a token has expired
user.tokens.first.expired?

# find user by token
User.find_by_token(:activate, "ea2f14aeac40")

# remove all expired tokens except those with NULL values
Token.clean

# generate a token as string, without saving it
User.generate_token

# remove a token by its name
user.remove_token(:activate)

# find user by valid token (same name, same hash, not expired)
User.find_by_valid_token(:activate, "ea2f14aeac40")

# find a token using class scope
User.find_token(:activate, "ea2f14aeac40")

# Token hash
token.to_s #=> ea2f14aeac40
```

## License

Copyright (c) 2008-2013 Nando Vieira, released under the MIT license

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
