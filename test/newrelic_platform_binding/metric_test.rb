require 'test_helper'

class MetricTest < Minitest::Test

  def setup
    @component = NewRelic::Binding::Component.new('name', 'com.test')
  end

  def test_component
    assert_equal @component, initialize_metric.component
  end

  def test_initialize_without_options_does_not_trigger_options_warning
    NewRelic::Logger.expects(:warn).never
    NewRelic::Binding::Metric.new(@component, 'Component/Test/rate[units]', '10')
  end

  def test_value
    assert_equal 10, initialize_metric.value
  end

  def test_count_without_options
    assert_equal 1, initialize_metric.count
  end

  def test_min_without_options
    assert_equal 10, initialize_metric.min
  end

  def test_max_without_options
    assert_equal 10, initialize_metric.max
  end

  def test_sum_of_squares_without_options
    assert_equal 10*10, initialize_metric.sum_of_squares
  end

  def test_count_with_only_count_option_set
    NewRelic::Logger.expects(:warn).with('Metric Component/Test/rate[units] count, min, max, and sum_of_squares are all required if one is set, falling back to value only')
    assert_equal 1, initialize_metric(:count => 2).count
  end

  def test_min_with_only_min_option_set
    NewRelic::Logger.expects(:warn).with('Metric Component/Test/rate[units] count, min, max, and sum_of_squares are all required if one is set, falling back to value only')
    assert_equal 10, initialize_metric(:min => 5).min
  end

  def test_max_with_only_max_option_set
    NewRelic::Logger.expects(:warn).with('Metric Component/Test/rate[units] count, min, max, and sum_of_squares are all required if one is set, falling back to value only')
    assert_equal 10, initialize_metric(:max => 15).max
  end

  def test_sum_of_squares_with_only_sum_of_squares_option_set
    NewRelic::Logger.expects(:warn).with('Metric Component/Test/rate[units] count, min, max, and sum_of_squares are all required if one is set, falling back to value only')
    assert_equal 100, initialize_metric(:sum_of_squares => 400).sum_of_squares
  end

  def test_hash
    assert_equal expected_hash, initialize_metric(:count => 2, :max => 15, :min => 5, :sum_of_squares => 250).to_hash
  end

  def test_initialize_with_string_for_value
    metric = NewRelic::Binding::Metric.new(@component, 'Component/Test/rate[units]', '10')
    hash = { 'Component/Test/rate[units]' => [10.0, 1, 10.0, 10.0, 100.0] }
    assert_equal hash, metric.to_hash
  end

  def test_initialize_with_string_for_value_and_options
    metric = NewRelic::Binding::Metric.new(@component, 'Component/Test/rate[units]', '10', :count => '2', :max => '15', :min => '5', :sum_of_squares => '250')
    hash = { 'Component/Test/rate[units]' => [10.0, 2, 5.0, 15.0, 250.0] }
    assert_equal hash, metric.to_hash
  end

  def test_aggregate_with_value
    metric = initialize_metric()
    metric2 = NewRelic::Binding::Metric.new(@component, 'Component/Test/rate[units]', 15)
    metric.aggregate(metric2)
    hash = { 'Component/Test/rate[units]' => [25.0, 2, 10.0, 15.0, 325.0] }
    assert_equal hash, metric.to_hash
  end

  def test_aggregate_with_value_and_options
    metric = initialize_metric()
    metric2 = NewRelic::Binding::Metric.new(@component, 'Component/Test/rate[units]', '20', :count => '2', :max => '15', :min => '5', :sum_of_squares => '250')
    metric.aggregate(metric2)
    hash = { 'Component/Test/rate[units]' => [30.0, 3, 5.0, 15.0, 350.0] }
    assert_equal hash, metric.to_hash
  end

  def initialize_metric(options = {})
    NewRelic::Binding::Metric.new(@component, 'Component/Test/rate[units]', 10, options)
  end

  def expected_hash
    { 'Component/Test/rate[units]' => [10, 2, 5, 15, 250] }
  end
end
