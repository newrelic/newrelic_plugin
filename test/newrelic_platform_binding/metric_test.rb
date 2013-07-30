require 'test_helper'

class MetricTest < Minitest::Test

  def setup
    @component = NewRelic::Binding::Component.new('name', 'com.test')
  end

  def test_component
    assert_equal @component, initialize_metric.component
  end

  def test_value
    assert_equal 10, initialize_metric.value
  end

  def test_count_without_options
    assert_equal 1, initialize_metric.count
  end

  def test_count_with_count_option_set
    assert_equal 2, initialize_metric(:count => 2).count
  end

  def test_min_without_options
    assert_equal 10, initialize_metric.min
  end

  def test_min_with_min_option_set
    assert_equal 5, initialize_metric(:min => 5).min
  end

  def test_max_without_options
    assert_equal 10, initialize_metric.max
  end

  def test_max_with_max_option_set
    assert_equal 15, initialize_metric(:max => 15).max
  end

  def test_sum_of_squares_without_options
    assert_equal 10*10, initialize_metric.sum_of_squares
  end

  def test_sum_of_squares_with_sum_of_squares_option_set
    assert_equal 400, initialize_metric(:sum_of_squares => 400).sum_of_squares
  end

  def test_hash
    expected = { 'Component/Test/rate[units]' => [10, 2, 15, 5, 250] }
    assert_equal expected, initialize_metric(:count => 2, :max => 15, :min => 5, :sum_of_squares => 250).to_hash
  end

  def initialize_metric(options = {})
    NewRelic::Binding::Metric.new(@component, 'Component/Test/rate[units]', 10, options)
  end
end
