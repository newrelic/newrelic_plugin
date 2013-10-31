require 'test_helper'

class EpochCounterTest < Minitest::Test

  def test_with_two_valid_pollcycles
    @counter = NewRelic::Processor::EpochCounter.new
    firstProcess = @counter.process(5)
    modify_counter_clock(@counter, 1)
    secondProcess = @counter.process(6)

    assert_nil(firstProcess)
    assert(secondProcess > 0)
  end

  def test_with_null_second_pollcycle
    @counter = NewRelic::Processor::EpochCounter.new
    firstProcess = @counter.process(5)
    modify_counter_clock(@counter, 1)
    secondProcess = @counter.process(nil)
    modify_counter_clock(@counter, 1)
    thirdProcess = @counter.process(6)
    modify_counter_clock(@counter, 1)
    fourthProcess = @counter.process(7)

    assert_nil(firstProcess)
    assert_nil(secondProcess)
    assert_nil(thirdProcess)
    assert(fourthProcess > 0)
  end

  def test_with_null_first_pollcycle
    @counter = NewRelic::Processor::EpochCounter.new
    firstProcess = @counter.process(nil)
    modify_counter_clock(@counter, 1)
    secondProcess = @counter.process(5)
    modify_counter_clock(@counter, 1)
    thirdProcess = @counter.process(6)

    assert_nil(firstProcess)
    assert_nil(secondProcess)
    assert(thirdProcess > 0)
  end

  def test_with_string_values
    @counter = NewRelic::Processor::EpochCounter.new
    firstProcess = @counter.process("5")
    modify_counter_clock(@counter, 1)
    secondProcess = @counter.process("6")
    modify_counter_clock(@counter, 1)
    thirdProcess = @counter.process(7)

    assert_nil(firstProcess)
    assert(secondProcess > 0)
    assert(thirdProcess > 0)
  end

  def modify_counter_clock(counter, seconds)
    time = counter.instance_variable_get(:@last_time)
    counter.instance_variable_set(:@last_time, counter.instance_variable_get(:@last_time) - seconds)
  end
end
