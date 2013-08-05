require 'test_helper'

class ContextTest < Minitest::Test

  def setup
    @context = NewRelic::Binding::Context.new('1.0.0', '192.168.1.1', '1234', 'license_key')
  end

  def test_that_create_component_returns_created_appointment
    assert_equal NewRelic::Binding::Component, @context.create_component('name', 'com.test').class
  end
end
