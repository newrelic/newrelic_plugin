require 'test_helper'

class NewRelicMessageTest < Test::Unit::TestCase
  def setup 
    @new_relic_message = NewRelic::Plugin::NewRelicMessage.new('foo', 'test component name', 'fake guid', 'version', 60)
  end

  context 'initialization' do
    should 'start with an empty metrics array' do
      assert_equal [], @new_relic_message.instance_variable_get(:@metrics)
    end
  end

  context :add_stat_fullname do
    setup do
      @new_relic_message.add_stat_fullname('test metric', 2, 2, :min => 1, :max => 3, :sum_of_squares => 10) 
    end
    should '@metric array should have 1 metric' do
      assert_equal 1, @new_relic_message.metrics.size
    end

    should '@metric array should include expected data' do
      stored_metric = {
        :metric_name => 'test metric',
        :count => 2,
        :total => 2,
        :min => 1,
        :max => 3,
        :sum_of_squares => 10
      }
      assert_equal stored_metric, @new_relic_message.metrics.first
    end
  end

  context :build_metrics_hash do
    setup do
      @new_relic_message.add_stat_fullname('test metric', 2, 2, :min => 1, :max => 3, :sum_of_squares => 10) 
      @new_relic_message.add_stat_fullname('other metric', 2, 2, :min => 2, :max => 2, :sum_of_squares => 8) 
    end

    should 'build expected metric hash' do
      metric_hash = {
        'test metric' => [2,2,3,1,10],
        'other metric' => [2,2,2,2,8]
      }
      assert_equal metric_hash, @new_relic_message.send(:build_metrics_hash)
    end
  end

  context :build_request_payload do
    setup do 
      @new_relic_message.add_stat_fullname('test metric', 2, 2, :min => 1, :max => 3, :sum_of_squares => 10) 
    end

    should 'build expected request payload' do
      payload = {
        'agent' => {
          'name' => 'test component name',
          'version' => 'version',
          'host' => ''
        },
        'components' => [
          {
            'name' => 'test component name',
            'guid' => 'fake guid',
            'duration' => 60,
            'metrics' => @new_relic_message.send(:build_metrics_hash)
          }
        ]
      }

      assert_equal payload.to_json, @new_relic_message.send(:build_request_payload)
    end
  end

end
