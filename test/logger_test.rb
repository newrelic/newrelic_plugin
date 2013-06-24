require 'test_helper'

class LoggerTest < Test::Unit::TestCase

  context 'self.write' do
    should 'build expected log string and output it' do
      NewRelic::Plugin::Logger.expects(:timestamp).returns('foobar')
      NewRelic::Plugin::Logger.expects(:output).with('[foobar] test')
      NewRelic::Plugin::Logger.write('test')
    end
  end

  context 'self.timestamp' do
    should 'format timestamp in iso8601' do
      test_time = Time.new(2013, 6, 24, 0, 0, 0, "+00:00")
      Time.expects(:now).returns(test_time)
      assert_equal '2013-06-24T00:00:00Z', NewRelic::Plugin::Logger.timestamp
    end
  end

end
