module NewRelic
  module Plugin
#
# Run class. Provides entry points and polling initiation support.
#
# Author:: Lee Atchison <lee@newrelic.com>
# Copyright:: Copyright (c) 2012 New Relic, Inc.
#
    class Run
      #
      # Primary Driver entry point
      #
      def self.setup_and_run component_type_filter=nil
        run=new
        run.setup_from_config component_type_filter
        run.setup_no_config_agents
        run.loop_forever
      end
      def initialize
        @poll_cycle = (NewRelic::Plugin::Config.config.newrelic["poll"] || 60).to_i
        @poll_cycle = 60 if (@poll_cycle <= 0) or (@poll_cycle >= 600)
        puts "WARNING: Poll cycle differs from 60 seconds (current is #{@poll_cycle})" if @poll_cycle!=60
      end
      def installed_agents
        if Setup.installed_agents.size==0
          puts "No agents installed!"
          raise NoAgents, "No agents installed"
        end
        Setup.installed_agents
      end
      #def installed_processors
      #  Setup.installed_processors
      #end
      def configured_agents
        agent_setup.agents
      end
      def setup_from_config component_type_filter=nil
        return unless NewRelic::Plugin::Config.config.agents
        installed_agents.each do |agent_id,installed_agent|
          next if component_type_filter and agent_id!=component_type_filter
          config_list=NewRelic::Plugin::Config.config.agents[agent_id.to_s]
          next unless config_list
          [config_list].flatten.each do |config|
            next unless config
            # Convert keys to symbols...
            config.keys.each {|key|config[(key.to_sym rescue key) || key] = config.delete(key)}
            name=config.delete(:name) # Pull out name and remove from hash
            agent_setup.create_agent agent_id,name,config
          end
        end
      end
      #
      # Add an entry for agents that require no configuration (and hence no instances)
      #
      def setup_no_config_agents
        installed_agents.each do |agent_id,installed_agent|
          unless installed_agent[:agent_class].config_required?
            agent_setup.create_agent agent_id,installed_agent[:agent_class].label,{}
          end
        end
      end
      def setup &block
        block.call(agent_setup)
      end
      #
      # Call this method to loop forever. This will delay an appropriate amount until
      # the next metric pull is needed, then it will loop thru all configured agents
      # and call each one in turn so it can perform it's appropriate metric pull.
      #
      def loop_forever
        if configured_agents.size==0
          err_msg = "No agents configured!"
          err_msg+= " Check the agents portion of your yml file." unless NewRelic::Plugin::Config.config.options.empty?
          puts err_msg
          raise NoAgents, err_msg
        end
        installed_agents.each do |agent_id,installed_agent|
          version = installed_agent[:agent_class].version
          puts "Agent #{installed_agent[:label]} is at version #{version}" if version
        end
        configured_agents.each do |agent|
          agent.startup if agent.respond_to? :startup
        end
        @done=false
        begin
          while !@done
            #
            # Set last run time
            @last_run_time=Time.now
            #
            # Call each agent
            cnt=0
            configured_agents.each do |agent|
              begin
                cnt+=agent.run @poll_cycle
              rescue => err
                puts "Error occurred in poll cycle: #{err}"
              end
            end
            puts "Gathered #{cnt} statistics"
            #
            # Delay until next run
            secs_to_delay=@poll_cycle-(Time.now-@last_run_time)
            sleep secs_to_delay if secs_to_delay>0
          end
        rescue Interrupt =>err
          puts "Shutting down..."
        end
        configured_agents.each do |agent|
          agent.shutdown if agent.respond_to? :shutdown
        end
        puts "Shutdown complete"
      end
      #private
      def agent_setup
        @agent_setup||=AgentSetup.new
      end
    end
  end
end
