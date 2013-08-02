require 'test_helper'
require 'fakeweb'

class RequestTest < Minitest::Test

  def setup
    FakeWeb.allow_net_connect = false
    @context = NewRelic::Binding::Context.new('1.0.0', '192.168.1.1', '1234', 'license_key')
  end

  def test_initialization_without_duration
    request = NewRelic::Binding::Request.new(@context)
    assert_equal nil, request.duration
  end

  def test_initialization_with_duration
    request = NewRelic::Binding::Request.new(@context, 60)
    assert_equal 60, request.duration
  end

  def test_add_metric_returns_a_metric
    metric_setup
    @metric = @request.add_metric(@component, 'Component/test_name', 10)
    assert_equal NewRelic::Binding::Metric, @metric.class
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

  def example_hash
    {
      'agent' => {
        'version' => '1.0.0',
        'host' => '192.168.1.1',
        'pid' => '1234'
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
    @component = @context.create_component('name', 'com.test')
    @request = NewRelic::Binding::Request.new(@context)
  end

end
