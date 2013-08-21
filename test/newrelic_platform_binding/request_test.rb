require 'test_helper'
require 'fakeweb'

class RequestTest < Minitest::Test

  def setup
    FakeWeb.allow_net_connect = false
    @context = NewRelic::Binding::Context.new('license_key')
  end

  def test_initialization
    request = NewRelic::Binding::Request.new(@context)
    assert_equal @context, request.context
  end

  def test_add_metric_returns_a_metric
    metric_setup
    @metric = @request.add_metric(@component, 'Component/test_name', 10)
    assert_equal NewRelic::Binding::Metric, @metric.class
  end

  def test_add_metric_does_not_aggregate_when_metric_does_not_already_exist
    metric_setup
    NewRelic::Binding::Metric.any_instance.expects(:aggregate).never
    @metric = @request.add_metric(@component, 'Component/test_name', 10)
  end

  def test_add_metric_aggregates_when_metric_already_exists
    metric_setup
    @metric = @request.add_metric(@component, 'Component/test_name', 10)
    @metric.expects(:aggregate)
    @request.add_metric(@component, 'Component/test_name', 10)
  end

  def test_find_metric_when_component_does_not_exist_yet
    metric_setup
    metric_name = 'Component/test_name'
    assert_equal nil, @request.send(:find_metric, @component, metric_name)
  end

  def test_find_metric_when_metric_does_not_exist
    metric_setup
    metric_name = 'Component/test_name'
    metric = @request.add_metric(@component, metric_name, 10)
    assert_equal nil, @request.send(:find_metric, @component, metric_name + '/foo')
  end

  def test_find_metric_when_metric_already_exists
    metric_setup
    metric_name = 'Component/test_name'
    metric = @request.add_metric(@component, metric_name, 10)
    assert_equal metric, @request.send(:find_metric, @component, metric_name)
  end

  def test_before_adding_metric_the_requests_metrics_data_structure_is_empty
    metric_setup
    assert_equal Hash.new, @request.instance_variable_get(:@metrics)
  end

  def test_after_adding_metric_the_requests_metrics_data_structure_contains_expected_data
    metric_setup
    @metric = @request.add_metric(@component, 'Component/test_name', 10)
    expected_hash = { 'namecom.test' => [@metric] }
    assert_equal expected_hash, @request.instance_variable_get(:@metrics)
  end

  def test_build_request_data_structure
    metric_setup
    @request.add_metric(@component, 'Component/test/first[units]', 1)
    @request.add_metric(@component, 'Component/test/second[units]', 2)
    assert_equal example_hash, @request.send(:build_request_data_structure)
  end

  def test_build_request_data_structure_when_component_has_no_metrics
    metric_setup
    ::NewRelic::Logger.expects(:warn).with("Component with name \"name\" and guid \"com.test\" had no metrics")
    @request.send(:build_request_data_structure)
  end

  def test_delivered_returns_false_after_initialization
    metric_setup
    assert_equal false, @request.delivered?
  end

  def test_delivered_returns_true_after_successful_delivery
    metric_setup
    ::NewRelic::Binding::Connection.any_instance.expects(:send_request).returns(true)
    @request.deliver
    assert_equal true, @request.delivered?
  end

  def test_delivered_returns_false_after_unsuccessful_delivery
    metric_setup
    ::NewRelic::Binding::Connection.any_instance.expects(:send_request).returns(false)
    @request.deliver
    assert_equal false, @request.delivered?
  end

  def example_hash
    {
      'agent' => {
        'version' => '1.0.0'
      },
      'components' => [
        {
          'name' => 'name',
          'guid' => 'com.test',
          'duration' => 60,
          'metrics' => {
             'Component/test/first[units]' => [1, 1, 1, 1, 1],
             'Component/test/second[units]' => [2, 1, 2, 2, 4]
          }
        }
      ]
    }
  end

  def metric_setup
    @context.version = '1.0.0'
    @component = @context.create_component('name', 'com.test')
    @request = NewRelic::Binding::Request.new(@context)
  end

end
