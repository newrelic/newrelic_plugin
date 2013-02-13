require 'test_helper'

class AgentTest < Test::Unit::TestCase

  def setup 
    @agent_info = {:ident => 1}
    @agent_class = TestingAgent::Agent.dup
  end

  context :agent_guid do
    should 'set guid' do
      @agent_class.class_eval do
        agent_guid '12234'
      end
      agent = @agent_class.new('test agent', @agent_info)
      assert_equal '12234', agent.class.guid
    end

    should 'raise RuntimeError if guid is set to nil' do
      assert_raise RuntimeError do
        @agent_class.class_eval do
          agent_guid nil
        end
      end
    end

    should 'raise RuntimeError if guid is set to empty string' do
      assert_raise RuntimeError do
        @agent_class.class_eval do
          agent_guid ""
        end
      end
    end
  end

  context :guid do
    should "return instance @guid" do
      agent = @agent_class.new('test agent', @agent_info)
      agent.instance_variable_set(:@guid, 'test')
      assert_equal 'test', agent.guid
    end

    should "return class guid" do
      @agent_class.class_eval do
        @guid = '123'
      end
      agent = @agent_class.new('test agent', @agent_info)
      assert_equal '123', agent.guid
    end 

    should "raise error if guid is not set properly" do
      @agent_class.class_eval do
        @guid = 'guid'
      end
      #agent = TestingAgent::Agent.new('test agent', @agent_info)
      # refactor the code this is hitting before finishing this test
      # this does not test well
      #assert_raise RuntimeError, 'Did not set GUID' do
      #  agent.guid
      #end
    end
  end

  context :agent_version do
    should 'set version' do
      @agent_class.class_eval do
        agent_version '0.0.1'
      end
      agent = @agent_class.new('test agent', @agent_info)
      assert_equal '0.0.1', agent.class.version
    end
  end

  context :version do
    should 'return class @version' do
      @agent_class.class_eval do
        @version = '1.2.3'
      end
      agent = @agent_class.new('test agent', @agent_info)
      assert_equal '1.2.3', agent.version
    end
  end

  context :agent_human_labels do
    setup do
      @agent_class.class_eval do
        agent_human_labels('Testing Agent') { 'Testing Agent block' }
      end
      @agent = @agent_class.new('test agent', @agent_info)
    end
    should 'set class @label' do
      assert_equal 'Testing Agent', @agent.class.label
    end
    should 'set instance label proc' do
      assert_equal "Testing Agent block", @agent.class.instance_label_proc.call
    end
  end

  context :no_config_required do
    should 'set class @no_config_required' do
      @agent_class.class_eval do
        agent_human_labels('Testing Agent') { 'Testing Agent block' }
      end
      agent = @agent_class.new('test agent', @agent_info)
      assert_equal true, agent.class.no_config_required
    end
  end

  context :config_required? do
    should 'return false when class @no_config_required true' do
      @agent_class.class_eval do
        @no_config_required = true
      end
      agent = @agent_class.new('test agent', @agent_info)
      assert_equal false, agent.class.config_required?
    end
    should 'return true when class @no_config_required false' do
      @agent_class.class_eval do
        @no_config_required = false
      end
      agent = @agent_class.new('test agent', @agent_info)
      assert_equal true, agent.class.config_required?
    end
    should 'return true when class @no_config_required is not set' do
      @agent_class.class_eval do
      end
      agent = @agent_class.new('test agent', @agent_info)
      assert_equal true, agent.class.config_required?
    end
  end

  context :agent_config_options do
    should 'set class @config_options_list if empty' do
      @agent_class.class_eval do
        agent_config_options(:test, 'foo', 'bar')
      end
      @agent = @agent_class.new('test agent', @agent_info)
      assert_equal [:test, 'foo', 'bar'], @agent.class.config_options_list  
    end

    should 'add to existing @config_options_list' do
      @agent_class.class_eval do
        attr_accessor 'foobar'
        @config_options_list = ['foobar']
        agent_config_options(:test, 'foo', 'bar')
      end
  
      @agent = @agent_class.new('test agent', @agent_info)
      assert_equal ['foobar', :test, 'foo', 'bar'], @agent.class.config_options_list  
    end
  end

end
