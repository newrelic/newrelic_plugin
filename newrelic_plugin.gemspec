Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.5'

  ## Leave these as is they will be modified for you by the rake gemspec task.
  s.name          = 'newrelic_plugin'
  s.version       = '0.2.11'
  s.date              = '2013-02-13'
  s.rubyforge_project = 'newrelic_plugin'

  ## Edit these as appropriate
  s.summary     = "New Relic Ruby Plugin SDK"
  s.description = <<-EOF
This is the core gem for developing plugins for New Relic.  It is used to 
send plugin data to New RElic from non-application sources.
  EOF

  s.authors       = ["Lee Atchison"]
  s.email         = ["lee@newrelic.com"]
  s.homepage =    'http://newrelic.com'

  s.require_paths = %w[lib]

  s.rdoc_options = ["--charset=UTF-8",
                    "--main", "README.rdoc"]
  s.extra_rdoc_files = %w[README.rdoc LICENSE]

  s.add_dependency 'faraday', '>= 0.8.1'
  s.add_dependency 'json'

  ## List your development dependencies here. Development dependencies are
  ## those that are only needed during development
  #s.add_development_dependency "minitest"
  #s.add_development_dependency "vcr"
  s.add_development_dependency 'shoulda-context'
  s.add_development_dependency 'mocha'

  ## Leave this section as-is. It will be automatically generated from the
  ## contents of your Git repository via the gemspec task. DO NOT REMOVE
  ## THE MANIFEST COMMENTS, they are used as delimiters by the task.
  # = MANIFEST =
  s.files = %w[
    Gemfile
    LICENSE
    README.rdoc
    Rakefile
    lib/newrelic_plugin.rb
    lib/newrelic_plugin/agent.rb
    lib/newrelic_plugin/config.rb
    lib/newrelic_plugin/data_collector.rb
    lib/newrelic_plugin/error.rb
    lib/newrelic_plugin/new_relic_connection.rb
    lib/newrelic_plugin/new_relic_message.rb
    lib/newrelic_plugin/processor.rb
    lib/newrelic_plugin/processors/epoch_counter_processor.rb
    lib/newrelic_plugin/processors/rate_processor.rb
    lib/newrelic_plugin/run.rb
    lib/newrelic_plugin/setup.rb
    lib/newrelic_plugin/simple_syntax.rb
    newrelic_plugin.gemspec
    test/agent_test.rb
    test/fixtures/valid_payload.json
    test/manual_test.rb
    test/new_relic_message_test.rb
    test/test_helper.rb
  ]
  # = MANIFEST =

  ## Test files will be grabbed from the file list. Make sure the path glob
  ## matches what you actually use.
  s.test_files = s.files.select { |path| path =~ /^test\/test_.*\.rb/ }

end
