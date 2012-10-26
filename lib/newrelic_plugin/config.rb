require 'yaml'
#
#
# Process global config file for NewRelic. This is defined per execution environment.
#
# Author:: Lee Atchison <lee@newrelic.com>
# Copyright:: Copyright (c) 2012 New Relic, Inc.
#
# The system configuration can be accessed as a hash using this method. For example:
#
#   plugin_config.config['xxx']
# or:
#   plugin_config.newrelic['...']
# or:
#   plugin_config.agents['...']
#
#
module NewRelic
  module Plugin
    class Config
      attr_reader :config
      # Creates an instance of a configuration object, loading the configuration
      # from the YAML configuration file. Note: this method should not be used
      # directly, rather the global method +config+ should be referenced instead.
      def initialize
        @config = YAML::load(Config.config_yaml) if Config.config_yaml
        @config = YAML.load_file(Config.config_file) unless @config
      end

      #
      # Return a hash of NewRelic configuration information.
      #
      # Usage: plugin_config.newrelic[...]
      #
      def newrelic
        @config["newrelic"]
      end
      #
      # Return a hash of agent configuration information.
      #
      # Usage: plugin_config.agents[...]
      #
      def agents
        @config["agents"]
      end

      #
      # Set the name of the configuration file:
      #
      #   NewRelic::Plugin::Config.config_file="lib/config.yml"
      #
      def self.config_file= config_file
        @config_file=config_file
        @config_yaml=nil
        @config_hash=nil
      end
      def self.config_file
        @config_file||="config/newrelic_plugin.yml"
      end
      #
      # Set the content of the configuration as a YAML string
      #
      #   NewRelic::Plugin::Config.config_yaml="newrelic:\n  test: 2\n  test2: four\nagents:\n  test: 4\n  test2: six\n"
      #
      def self.config_yaml= config_yaml
        @config_yaml=config_yaml
        @config_file=nil
        @config_hash=nil
      end
      def self.config_yaml
        @config_yaml
      end
      #
      # Returns a memoized version of the configuration object.
      #
      def self.config
        @config_hash||=NewRelic::Plugin::Config.new
      end
    end
  end
end
def plugin_config
  NewRelic::Plugin::Config.config
end
