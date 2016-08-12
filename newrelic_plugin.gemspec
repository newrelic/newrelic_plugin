# -*- encoding: utf-8 -*-
require File.expand_path('../lib/newrelic_plugin/version', __FILE__)

Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.5'

  ## Leave these as is they will be modified for you by the rake gemspec task.
  s.name          = 'newrelic_plugin'
  s.version       = NewRelic::Plugin::VERSION
  s.rubyforge_project = 'newrelic_plugin'

  ## Edit these as appropriate
  s.summary     = "New Relic Ruby Plugin SDK"
  s.description   = %q{The New Relic Plugin Gem is used to send plugin data to New Relic from non-application sources.}

  s.authors       = ["New Relic"]
  s.email         = ["support@newrelic.com"]
  s.homepage =    'http://newrelic.com'

  s.require_paths = %w[lib]

  s.rdoc_options = ["--charset=UTF-8",
                    "--main", "README.md"]
  s.extra_rdoc_files = %w[README.md LICENSE]

  s.add_dependency 'json', '= 1.8.3'

  ## List your development dependencies here. Development dependencies are
  ## those that are only needed during development
  s.add_development_dependency 'mocha'
  s.add_development_dependency "minitest", '>= 5.0.6'
  s.add_development_dependency 'fakeweb'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'timecop', '= 0.6.1'

  s.files         = `git ls-files`.split($\)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})


  ## Test files will be grabbed from the file list. Make sure the path glob
  ## matches what you actually use.
  s.test_files = s.files.select { |path| path =~ /^test\/test_.*\.rb/ }

end
