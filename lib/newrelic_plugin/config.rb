require 'yaml'
require 'erb'
module NewRelic
  module Plugin
#
#
# Process global config file for NewRelic. This is defined per execution environment.
#
# Author:: Lee Atchison <lee@newrelic.com>
# Copyright:: Copyright (c) 2012 New Relic, Inc.
#
# The system configuration can be accessed as a hash using this method. For example:
#
#   NewRelic::Plugin::Config.config.options['xxx']
# or:
#   NewRelic::Plugin::Config.config.newrelic['...']
# or:
#   NewRelic::Plugin::Config.config.agents['...']
#
#
    class Config
      attr_reader :options
      # Creates an instance of a configuration object, loading the configuration
      # from the YAML configuration file. Note: this method should not be used
      # directly, rather the global method +config+ should be referenced instead.
      def initialize
        @options = YAML::load(Config.config_yaml) if Config.config_yaml
        @options = YAML.load_file(ERB.new(File.read(Config.config_file), 0, '<>').result) unless @options
      end

      #
      # Return a hash of NewRelic configuration information.
      #
      # Usage: NewRelic::Plugin::Config.config.newrelic[...]
      #
      def newrelic
        @options["newrelic"]
      end
      #
      # Return a hash of agent configuration information.
      #
      # Usage: NewRelic::Plugin::Config.config.agents[...]
      #
      def agents
        @options["agents"]
      end

      #
      # Set the name of the configuration file:
      #
      #   NewRelic::Plugin::Config.config_file="lib/config.yml"
      #
      def self.config_file= config_file
        @config_file=config_file
        @config_yaml=nil
        @instance=nil
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
        @instance=nil
      end
      def self.config_yaml
        @config_yaml
      end
      #
      # Returns a memoized version of the configuration object.
      #
      def self.config
        @instance||=NewRelic::Plugin::Config.new
      end
    end
  end
end
def plugin_config
  NewRelic::Plugin::Config.config
end
