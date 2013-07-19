module NewRelic
  module Plugin
#
# Primary newrelic_plugin agent.
#
# Author:: Lee Atchison <lee@newrelic.com>
# Copyright:: Copyright (c) 2012 New Relic, Inc.
#
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
              @config_options_list << config
            end
          end
        end

        #
        # Instance Info
        #
        attr_reader :name
        def guid
          return @guid if @guid
          @guid = self.class.guid
          #
          # Verify GUID is set correctly...
          #
          invalid_guids = ["", "guid", "_TYPE_YOUR_GUID_HERE_"]
          raise "Did not set GUID" if @guid.nil? or invalid_guids.include?(@guid)
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
        def initialize context, options = {}
          @context = context
          @options = options
          if self.class.config_options_list
            self.class.config_options_list.each do |config|
              self.send("#{config}=",options[config])
            end
          end
          @last_time = nil

          #
          # Run agent-specific metric setup, if necessary
          setup_metrics if respond_to? :setup_metrics
          @component = @context.create_component(instance_label, guid)
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
        def report_metric(metric_name, units, value, opts = {} )
          return if value.nil?
          @request.add_metric(@component, "Component/#{metric_name}[#{units}]", value, opts)
        end

        #
        #
        # Execute a poll cycle
        #
        #
        def run(request)
          @request = request
          #
          # Start of cycle work, if any
          cycle_start if respond_to? :cycle_start

          #
          # Collect Data
          poll_cycle

          #
          # End of cycle work, if any
          cycle_end if respond_to? :cycle_end
        end
      end
    end
  end
end
