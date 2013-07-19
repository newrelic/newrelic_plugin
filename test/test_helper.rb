require 'rubygems'
require 'bundler'
Bundler.setup
require 'newrelic_plugin'
require 'test/unit'
require 'shoulda-context'
require 'mocha/setup'


module TestingAgent
  class Agent < NewRelic::Plugin::Agent::Base
    agent_guid 'com.newrelic.test'
    agent_version '0.0.1'
    agent_human_labels("Testing") { "Testing host" }
  end
end

