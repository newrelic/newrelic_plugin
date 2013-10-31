module NewRelic::Processor
class EpochCounter<NewRelic::Plugin::Processor::Base
    def initialize
      super :epoch_counter, "Epoch Counter"
    end

    def process val
      ret = nil
      curr_time = Time.now

      if val && @last_value && @last_time && curr_time > @last_time
        val = val.to_f
        ret = (val - @last_value.to_f) / (curr_time - @last_time).to_f
      end

      @last_value = val
      @last_time = curr_time

      # This next line is to avoid large negative spikes during epoch reset events...
      return nil if ret.nil? || ret < 0
      ret
    end

    #Component::Setup.install_processor EpochCounter
  end
end
