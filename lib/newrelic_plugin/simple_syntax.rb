module NewRelic
  module Plugin
#
#
# SimpleSyntax:
#
# This is prototype code...the interface is not finalized nor is the implementation
# complete. It's proof-of-concept only and subject to change without notice.
#
#
    module SimpleSyntax
      class Agent < NewRelic::Plugin::Agent::Base
        no_config_required
        class << self
          def guid= guid
            agent_guid guid
          end
          def version= version
            agent_version version
          end
          def human_labels label,&block
            agent_human_labels label,&block
          end
          def poll_cycle_proc= block
            @@poll_cycle_proc = block
          end
        end
        def poll_cycle
          mod=Module.new
          mod.send :define_method,:call_poll_cycle,@@poll_cycle_proc
          self.extend mod
          self.call_poll_cycle self
        end
      end
    end

    def self.setup
      yield SimpleSyntax::Agent
    end

    def self.agent_config
    end

    def self.poll_cycle &block
      SimpleSyntax::Agent.poll_cycle_proc = block
    end

    def self.run
      NewRelic::Plugin::Setup.install_agent :simple_syntax,NewRelic::Plugin::SimpleSyntax
      NewRelic::Plugin::Run.setup_and_run
    end

  end
end
