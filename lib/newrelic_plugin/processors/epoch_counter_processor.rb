module NewRelic::Processor
class EpochCounter<NewRelic::Plugin::Processor::Base
    def initialize
      super :epoch_counter,"Epoch Counter"
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
      # This next line is to avoid large negative spikes during epoch reset events...
      return nil if ret.nil? or ret<0
      ret
    end
    #Component::Setup.install_processor EpochCounter
  end
end
