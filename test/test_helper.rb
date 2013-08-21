require 'rubygems'
require 'bundler'
Bundler.setup
require 'newrelic_platform_binding'
require 'newrelic_plugin'
require 'minitest/autorun'
require 'mocha/setup'
require 'pry'


module TestingAgent
  class Agent < NewRelic::Plugin::Agent::Base
    agent_guid 'com.newrelic.test'
    agent_version '0.0.1'
    agent_human_labels("Testing") { "Testing host" }
  end

  NewRelic::Plugin::Setup.install_agent 'testing_agent', TestingAgent
end

