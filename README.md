# GreenhouseApi

This is an API Client for working with the [Greenhouse Harvest API](https://developers.greenhouse.io/harvest.html). It's lightweight and supports fetching all pages by default.

```ruby
client = GreenhouseApi::Client.new(api_key)

# Get all candidates
client.list_candidates

# Get other resources type
client.list_many('departments', limit: 5)

# Get current offer for application
client.get_current_offer_for_application(12345)

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

To install this gem onto your local machine, run `gem install greenhouse_api`. To release a new version, update the version number in `version.rb`, and then run `gem build`, which will create a new version of the gem. To publish these changes to [rubygems.org](https://rubygems.org), do the following:
1. Open up a PR for this repo with your changes.
2. After the PR is merged into the `main` branch, publish your changes by running `gem push greenhouse_api-<version>.gem`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gusto/greenhouse_api.

