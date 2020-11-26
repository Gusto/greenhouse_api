# GreenhouseApi

This is an API Client for working with the [Greenhouse Harvest API](https://developers.greenhouse.io/harvest.html). It's lightweight and supports fetching all pages by default.

```ruby
client = GreenhouseApi::Client.new(api_key)

# Get all candidates
client.list_candidates

# Get other resources type
client.list_many('departments', limit: 5)
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'greenhouse_api'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install greenhouse_api

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gusto/greenhouse_api.

