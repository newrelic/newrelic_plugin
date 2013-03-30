require 'rubygems'
require 'bundler'
Bundler.setup
require 'newrelic_plugin'
require 'test/unit'
require 'shoulda-context'
require 'mocha/setup'


module TestingAgent
  class Agent < NewRelic::Plugin::Agent::Base
    def self.instance_label; ''; end
  end
end

