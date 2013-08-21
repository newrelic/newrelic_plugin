require 'test_helper'


class SetupTest < Minitest::Test

  def setup
    @context = NewRelic::Binding::Context.new('license_key')
  end


  def test_create_agent
    setup = NewRelic::Plugin::AgentSetup.new
    @context.expects(:version=).with('0.0.1')
    setup.create_agent(@context, 'testing_agent', nil)
  end

end
