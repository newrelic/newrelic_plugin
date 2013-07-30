module NewRelic::Processor
  #
  #
  # OBSOLESCENCE WARNING!!!
  #
  # The "Rate" processor is being obsoleted. Please do not use in any new agent
  # development.
  #
  # If you feel you need this processor, please check out the "Epoch Counter" processor
  # and see if that will meet your needs. If not, then you can always do this calculation
  # yourself within your agent.
  #
  # This processor will be removed from the code base shortly...
  #
  #
  class Rate < NewRelic::Plugin::Processor::Base
    def initialize
      Logger.warn("OBSOLESCENCE WARNING: The 'Rate' processor is obsolete and should not be used.")
      Logger.warn("OBSOLESCENCE WARNING: It will be completely removed in the near future.")
      super :rate,"Rate"
    end
    def process val
      val=val.to_f
      ret=nil
      curr_time=Time.now
      if @last_value and @last_time and curr_time>@last_time
        ret=(val-@last_value)/(curr_time-@last_time).to_f
      end
      @last_value=val
      @last_time=curr_time
      ret
    end
    #Component::Setup.install_processor Rate
  end
end
