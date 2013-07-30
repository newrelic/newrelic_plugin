require 'test_helper'

class AgentTest < Minitest::Test

  def setup
    @agent_class = TestingAgent::Agent.dup
    @context = NewRelic::Binding::Context.new('1.0.0', 'localhost', '0', 'license_key')
  end

  def test_agent_guid_should_set_guid
    @agent_class.class_eval do
      agent_guid '12234'
    end
    agent = @agent_class.new(@context)
    assert_equal '12234', agent.class.guid
  end

  def test_agent_guid_should_raise_if_guid_is_set_to_nil
    assert_raises RuntimeError do
      @agent_class.class_eval do
        agent_guid nil
      end
    end
  end

  def test_agent_guid_should_raise_if_guid_is_set_to_empty_string
    assert_raises RuntimeError do
      @agent_class.class_eval do
        agent_guid ""
      end
    end
  end

  def test_guid_should_return_instance_guid
    agent = @agent_class.new(@context)
    agent.instance_variable_set(:@guid, 'test')
    assert_equal 'test', agent.guid
  end

  def test_guid_should_return_class_guid
    @agent_class.class_eval do
      @guid = '123'
    end
    agent = @agent_class.new(@context)
    assert_equal '123', agent.guid
  end

  def test_agent_version_should_set_version
    @agent_class.class_eval do
      agent_version '0.0.1'
    end
    agent = @agent_class.new(@context)
    assert_equal '0.0.1', agent.class.version
  end

  def test_agent_class_should_return_class_version
    @agent_class.class_eval do
      @version = '1.2.3'
    end
    agent = @agent_class.new(@context)
    assert_equal '1.2.3', agent.version
  end

  def test_agent_human_labels_should_set_class_label
    @agent_class.class_eval do
      agent_human_labels('Testing Agent') { 'Testing Agent block' }
    end
    agent = @agent_class.new(@context)
    assert_equal 'Testing Agent', agent.class.label
  end

  def test_agent_human_labels_should_set_instance_label_proc
    @agent_class.class_eval do
      agent_human_labels('Testing Agent') { 'Testing Agent block' }
    end
    agent = @agent_class.new(@context)
    assert_equal "Testing Agent block", agent.class.instance_label_proc.call
  end

  def test_no_config_required_should_set_class_no_config_required
    @agent_class.class_eval do
      agent_human_labels('Testing Agent') { 'Testing Agent block' }
    end
    agent = @agent_class.new(@context)
    assert_equal true, agent.class.no_config_required
  end

  def test_config_required_should_return_false_when_class_no_config_required_true
    @agent_class.class_eval do
      @no_config_required = true
    end
    agent = @agent_class.new(@context)
    assert_equal false, agent.class.config_required?
  end
  def test_config_required_should_return_true_when_class_no_config_required_false
    @agent_class.class_eval do
      @no_config_required = false
    end
    agent = @agent_class.new(@context)
    assert_equal true, agent.class.config_required?
  end
  def test_config_required_should_return_true_when_class_no_config_required_is_not_set
    @agent_class.class_eval do
    end
    agent = @agent_class.new(@context)
    assert_equal true, agent.class.config_required?
  end

  def test_agent_config_options_should_set_class_config_options_list_if_empty
    @agent_class.class_eval do
      agent_config_options(:test, 'foo', 'bar')
    end
    @agent = @agent_class.new(@context)
    assert_equal [:test, 'foo', 'bar'], @agent.class.config_options_list
  end

  def test_agent_config_options_should_add_to_existing_config_options_list
    @agent_class.class_eval do
      attr_accessor 'foobar'
      @config_options_list = ['foobar']
      agent_config_options(:test, 'foo', 'bar')
    end

    @agent = @agent_class.new(@context)
    assert_equal ['foobar', :test, 'foo', 'bar'], @agent.class.config_options_list
  end
end
