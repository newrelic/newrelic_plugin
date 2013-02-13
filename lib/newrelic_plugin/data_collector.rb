module NewRelic
  module Plugin
#
# Gather's data from agent and presents it to nr_connect for processing.
#
# This is a wrapper for nr_connect used in the context of an agent.
#
    class DataCollector
      #
      #
      # Methods used within an agent implementation:
      #
      #
      def add_data metric_name,units,data,opts={}
        nrmsg.add_stat_fullname(
            "Component/#{metric_name}[#{units}]",
            1,
            data,
            :min => data,
            :max => data,
            :sum_of_squares => (data*data)
        )
        #puts "Metric '#{metric_name}' (#{units}): raw: #{value}, processed: #{data} (#{processor_type})" if verbose?
        @cnt+=1
        data
      end


      #
      # Internal methods used within Agent class
      #
      def initialize agent,poll_interval
        @agent=agent
        @poll_interval=poll_interval
        @cnt=0
      end
      def process
        nrmsg_send
        @cnt
      end

      ################################################################################
      private

      def verbose?
        return @verbose unless @verbose.nil?
        @verbose=NewRelic::Plugin::Config.config.newrelic["verbose"].to_i>0
      end

      #
      # NewRelicConnection Handling
      #
      def nrmsg
        @nrmsg||=nrobj.start_message @agent.instance_label,@agent.guid,@agent.version,@poll_interval
      end
      def nrmsg_send
        return unless @nrmsg
        @nrmsg.send_metrics
        @nrmsg=nil
      end
      def nrobj
        @nrobj||=NewRelic::Plugin::NewRelicConnection.new NewRelic::Plugin::Config.config.newrelic
      end

    end
  end
end
