require 'test_helper'

class ContextTest < Minitest::Test

  def setup
    @context = NewRelic::Binding::Context.new('license_key')
  end

  def test_that_create_component_returns_created_appointment
    assert_equal NewRelic::Binding::Component, @context.create_component('name', 'com.test').class
  end

  def test_that_get_request_returns_a_request
    assert_equal NewRelic::Binding::Request, @context.get_request.class
  end

  def test_that_get_request_returns_the_same_request_if_the_request_has_not_been_delivered
    request = @context.get_request
    assert_equal request, @context.get_request
  end

  def test_that_get_request_returns_a_new_request_if_the_aggregation_limit_is_reached
    Timecop.freeze(Time.now - 25 * 60)
    context = NewRelic::Binding::Context.new('license_key')
    request = context.get_request
    Timecop.return
    assert request != context.get_request
  end

  def test_that_get_request_returns_a_new_request_if_the_request_has_been_delivered
    request = @context.get_request
    request.expects(:delivered?).returns(true)
    assert request != @context.get_request
  end
end
