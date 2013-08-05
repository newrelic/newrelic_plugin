require 'test_helper'

class ComponentTest < Minitest::Test

  def setup
    @component = NewRelic::Binding::Component.new('name', 'com.test')
  end

  def test_that_component_responds_to_name
    assert_equal 'name', @component.name
  end

  def test_that_component_responds_to_guid
    assert_equal 'com.test', @component.guid
  end
end
