#
# Setup support methods.
#
# Author:: Lee Atchison <lee@newrelic.com>
# Copyright:: Copyright (c) 2012 New Relic, Inc.
#
module NewRelic
  module Plugin
    #
    # Setup and Register new agent types and new processors
    #
    class Setup
      class << self
        def install_agent ident,klass
          @installed_agents||={}
          @installed_agents[ident] = {
              agent_class: klass::Agent,
              label: klass::Agent.label,
              ident: ident
          }
        end
        #def install_processor klass
        #  @installed_processors||={}
        #  tmp_instance=klass.new
        #  @installed_processors[tmp_instance.ident]={ident: tmp_instance.ident,processor_class: klass,label: tmp_instance.label}
        #end
        def installed_agents
          @installed_agents||{}
        end
        #def installed_processors
        #  @installed_processors||{}
        #end
      end
    end

    #
    # Setup and instantiate new agent instances (of agent type previously setup in NewRelic::Plugin::Setup)
    #
    class AgentSetup
      attr_reader :agents
      def initialize
        @agents=[]
      end
      def create_agent ident,name,options=nil,&block
        agent_info=Setup.installed_agents[ident]
        raise UnknownInstalledAgent,"Unrecognized agent '#{ident}'" unless agent_info
        agent=agent_info[:agent_class].new name,agent_info,options
        raise CouldNotInitializeAgent unless agent
        block.call(agent) if block_given?
        @agents<<agent
      end
    end
  end
end
