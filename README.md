# Authoraise

This gem is not like other authorization gems because it doesn't enforce any kind of structure or vocabulary on your app. Its only job is to wrap and audit your boolean expressions that you use for authorization.

So instead of writing boolean expressions like this.

~~~ruby
  options[:post] &&
    (options[:post].publised? || (options[:post].user == options[:user]))
~~~

You would write them like this.

~~~ruby
  policy = Authoraise::Policy.new
  policy.allow { |post| post.published? }
  policy.allow { |post, user| post.user == user }
  policy.authorize(options)
~~~

Or like this.

~~~ruby
  authorize(options) do |policy|
    policy.allow { |post| post.published? }
    policy.allow { |post, user| post.user == user }
  end
~~~

You may wonder why would you do that. Well, when your authorization logic gets more complex, you might start forgetting to pass in all the options that are used to check access. When that happens, your boolean expressions return false, causing false negatives. Take a look at the first example above, and think what happens if post is not published and `options[:user]` is not passed in. Hint: you just get a `false`. Your program would lie to you, because really you never gave it a user to check, so how does it know if it's a false? It's straight up missing some data.

This gem solves the problem by raising helpful error messages, but also allowing you to ignore the issue where it's intended to be that way. So in the examples above if you pass an unpublished post and forget to pass in a user in the options, you will see a helpful error message.

## Usage

Follow these examples to understand how things work in various cases.

~~~ruby
require 'authoraise'

# Authorization policy can be defined as follows...
policy = Authoraise::Policy.new
policy.allow { |user| user == 'sammy' }
policy.allow { |post| post == 'happy_post' }

# ...and used as follows.
policy.authorize(user: 'sammy', post: 'happy_post') # => true
policy.authorize(user: 'bob',   post: 'happy_post') # => true
policy.authorize(user: 'bob',   post: 'sad_post')   # => false
policy.authorize(user: 'sammy')                     # => true

# Another way is to both define and run a policy using this block form.
include Authoraise
authorize(user: 'sammy', post: 'article') do |policy|
  policy.allow { |user| user == 'sammy' }
end
# => true

# Oops, in this example I forgot to pass the post, but user also didn't match.
authorize(user: 'bob') do |policy|
  policy.allow { |user| user == 'sammy' }
  policy.allow { |post| post == 'foo' }
end
# => Authoraise::Error: Inconclusive authorization, missing keys: [:post]

# Forgot to pass the post object, but user was actually enough.
authorize(user: 'sammy') do |policy|
  policy.allow { |user| user == 'sammy' }
  policy.allow { |post| post == 'foo' }
end
# => true

# Didn't forget to pass anything, but it didn't match, so this is a legit fail.
authorize(user: 'bob', post: 'foo') do |policy|
  policy.allow { |user| user == 'sammy' }
  policy.allow { |post| post == 'bar' }
end
# => false

# Let's see what happens in strict mode.
Authoraise.strict_mode = true

# In strict mode any missing key raises an error, even if other checks passed.
authorize(user: 'sammy') do |policy|
  policy.allow { |user| user == 'sammy' }
  policy.allow { |post| post == 'foo' }
end
# => Authoraise::Error: Strict mode found missing keys: [:post]
~~~

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'authoraise'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install authoraise

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/authoraise/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
