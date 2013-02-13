require 'rubygems'
require 'bundler'
Bundler.setup
require 'newrelic_plugin'
require 'test/unit'
require 'shoulda-context'
require 'mocha'


module TestingAgent
  class Agent < NewRelic::Plugin::Agent::Base

  end
end

