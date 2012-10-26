# -*- encoding: utf-8 -*-
require File.expand_path('../lib/newrelic_plugin/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Lee Atchison"]
  gem.email         = ["lee@newrelic.com"]
  gem.description   = %q{New Relic newrelic_plugin Gem, used to create newrelic_plugin drivers for storing data into New Relic from non-application sources.}
  gem.summary       = %q{New Relic newrelic_plugin Gem}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "newrelic_plugin"
  gem.require_paths = ["lib"]
  gem.version       = NewRelic::Plugin::VERSION

  gem.add_development_dependency "minitest"
  gem.add_development_dependency "vcr"
  gem.add_runtime_dependency 'faraday', '>= 0.8.1'
end
