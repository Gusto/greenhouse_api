require_relative 'lib/greenhouse_api/version'

Gem::Specification.new do |spec|
  spec.name          = "greenhouse_api"
  spec.version       = GreenhouseApi::VERSION
  spec.authors       = ["Florence Lau", "Tanner Johnson", "Quan Nguyen"]
  spec.email         = ["quan.nguyen@gusto.com"]

  spec.summary       = "API client for working with Greenhouse Harvest API"
  spec.description   = "API client for working with Greenhouse Harvest API"
  spec.homepage      = "https://github.com/gusto/greenhouse_api"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # # Specify which files should be added to the gem when it is released.
  # # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  # spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
  #   `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  # end
  spec.files = Dir['lib/**/*.rb']
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", '>= 0.15.4'
  spec.add_dependency 'sorbet-runtime', '>= 0.5'

  spec.add_development_dependency "rspec", "~> 3.10"
  spec.add_development_dependency 'sorbet', '>= 0.5'
  spec.add_development_dependency "vcr", "~> 6"
  spec.add_development_dependency "webmock", "~> 3.10"
end
