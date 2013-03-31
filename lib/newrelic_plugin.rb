require "newrelic_plugin/error"
require "newrelic_plugin/config"
require "newrelic_plugin/new_relic_connection"
require "newrelic_plugin/new_relic_message"
require "newrelic_plugin/agent"
require "newrelic_plugin/data_collector"
require "newrelic_plugin/setup" # cleanup needed
require "newrelic_plugin/run" # cleanup needed
require "newrelic_plugin/processor"
require "newrelic_plugin/processors/epoch_counter_processor" # port needed
require "newrelic_plugin/processors/rate_processor" # port needed

module NewRelic
  module Plugin
    VERSION = "0.2.12"
  end
  module Processor
  end
end
