require 'test_helper'
require 'timecop'

class EpochCounterTest < Test::Unit::TestCase
  context :process do
    # This nil behavior seems dubious, but it is the current behavior
    should "return nil when no previous value was processed" do
      counter = NewRelic::Processor::EpochCounter.new
      assert_equal nil, counter.process(1)
    end
    should "return nil when multiple values are processed in the same second" do
      counter = NewRelic::Processor::EpochCounter.new
      Timecop.freeze(Time.now) do
        counter.process(1)
        assert_equal nil, counter.process(9001)
      end
    end

    should "return the change in value per second" do
      start_time = Time.local(2013, 3, 3, 12, 0, 0)
      Timecop.freeze(start_time)
      counter = NewRelic::Processor::EpochCounter.new
      counter.process(1)

      Timecop.freeze(start_time + 1)
      assert_equal 2, counter.process(3)

      Timecop.return
    end

    should "return the fractional change in value per second" do
      start_time = Time.local(2013, 3, 3, 12, 0, 0)
      Timecop.freeze(start_time)
      counter = NewRelic::Processor::EpochCounter.new
      counter.process(1)

      Timecop.freeze(start_time + 2)
      assert_equal 0.5, counter.process(2)

      Timecop.return
    end
  end
end
