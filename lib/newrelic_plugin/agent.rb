#
# Primary newrelic_plugin agent.
#
# Author:: Lee Atchison <lee@newrelic.com>
# Copyright:: Copyright (c) 2012 New Relic, Inc.
#
module NewRelic
  module Plugin
    module Agent
      class Base
        class << self
          attr_reader :label,:instance_label_proc,:guid,:version
          attr_accessor :config_options_list


          #
          # Define the GUID for this agent.
          #
          def agent_guid str
            raise "Did not set GUID" if str.nil? or str==""
            @guid=str
          end

          #
          # Define version for this agent
          #
          def agent_version str
            @version = str
          end

          #
          #
          # Human Readable labels for plugin.
          #   label - Name of the plugin
          #   block return - Name of a particular instance of a plugin component.
          #
          #
          def agent_human_labels label,&block
            @label=label
            @instance_label_proc=block
          end

          #
          #
          # Support for single instance, non-configurable agents.
          #
          #
          def no_config_required
            @no_config_required=true
          end
          def config_required?
            !@no_config_required
          end

          #
          #
          # Specify name of configuration values used in plugin implementation.
          #
          #
          def agent_config_options *args
            @config_options_list||=[]
            args.each do |config|
              attr_accessor config
              @config_options_list<<config
            end
          end
        end

        #
        # Instance Info
        #
        attr_reader :name,:agent_info
        def guid
          return @guid if @guid
          @guid=self.class.guid
          #
          # Verify GUID is set correctly...
          #
          if @guid=="guid" or @guid=="DROP_GUID_FROM_PLUGIN_HERE"
            @guid = plugin_config.newrelic['guids'][agent_info[:ident].to_s] if plugin_config.newrelic['guids']
            puts "NOTE: GUID updated for #{instance_label} at run-time to '#{@guid}'"
          end
          raise "Did not set GUID" if @guid.nil? or @guid=="" or @guid=="guid" or @guid=="DROP_GUID_FROM_PLUGIN_HERE"
          @guid
        end
        def version
          self.class.version
        end
        def label
          self.class.label
        end
        #
        # Instantiate a newrelic_plugin instance
        def initialize name,agent_info,options={}
          @name=name
          @agent_info=agent_info
          @ident=agent_info[:ident]
          @options=options
          if self.class.config_options_list
            self.class.config_options_list.each do |config|
              self.send("#{config}=",options[config])
            end
          end
          @last_time=nil

          #
          # Run agent-specific metric setup, if necessary
          setup_metrics if respond_to? :setup_metrics
        end
        def instance_label
          if !respond_to? :instance_label_proc_method
            mod=Module.new
            mod.send :define_method,:instance_label_proc_method,self.class.instance_label_proc
            self.extend mod
          end
          self.instance_label_proc_method
        end

        #
        #
        # Setup & Report Metrics
        #
        #
        def report_metric metric_name,units,value,opts={}
          return if value.nil?
          @data_collector.add_data metric_name,units,value.to_f,opts
        end

        #
        #
        # Execute a poll cycle
        #
        #
        def run poll_interval
          #
          # Start of cycle work, if any
          cycle_start if respond_to? :cycle_start

          #
          # Collect Data
          @data_collector=DataCollector.new self,poll_interval
          poll_cycle
          cnt=@data_collector.process
          @data_collector=nil

          #
          # End of cycle work, if any
          cycle_end if respond_to? :cycle_end
          cnt
        end
      end
    end
  end
end
