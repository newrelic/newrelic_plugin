module NewRelic::Processor
  class Rate<NewRelic::Plugin::Processor::Base
    def initialize
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
