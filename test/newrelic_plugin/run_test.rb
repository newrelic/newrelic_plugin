require 'test_helper'

class RunTest < Minitest::Test
  TestConfig = Struct.new(:newrelic)
  def setup
    @newrelic = {
    }
  end

  def test_log_level_set_verbose
    NewRelic::PlatformLogger.expects(:log_level=).with(::Logger::DEBUG)
    @newrelic['verbose'] = 1
    initialize_run
  end

  def test_log_level_not_set
    NewRelic::PlatformLogger.expects(:log_level=).never
    initialize_run
  end

  def test_log_level_set_to_not_verbose
    NewRelic::PlatformLogger.expects(:log_level=).never
    @newrelic['verbose'] = 0
    initialize_run
  end

  def test_endpoint_config
    NewRelic::Binding::Config.expects(:endpoint=).with('http://test.com')
    @newrelic['endpoint'] = 'http://test.com'
    initialize_run
  end

  def test_ssl_host_verification_nil
    NewRelic::Binding::Config.expects(:ssl_host_verification=).never
    initialize_run
  end

  def test_ssl_host_verification_string
    NewRelic::Binding::Config.expects(:ssl_host_verification=).with(true)
    @newrelic['ssl_host_verification'] = 'foo'
    initialize_run
  end

  def test_ssl_host_verification_false
    NewRelic::Binding::Config.expects(:ssl_host_verification=).with(false)
    @newrelic['ssl_host_verification'] = false
    initialize_run
  end

  def test_ssl_host_verification_true
    NewRelic::Binding::Config.expects(:ssl_host_verification=).with(true)
    @newrelic['ssl_host_verification'] = true
    initialize_run
  end

  def test_proxy
    NewRelic::Binding::Config.expects(:proxy=).with('foobar')
    @newrelic['proxy'] = 'foobar'
    initialize_run
  end

  def test_poll_cycle_period_without_poll_set
    NewRelic::Binding::Config.expects(:poll_cycle_period=).with(60)
    initialize_run
  end

  def test_poll_cycle_period_with_poll_set
    NewRelic::Binding::Config.expects(:poll_cycle_period=).with(20)
    @newrelic['poll'] = 20
    initialize_run
  end

  def initialize_run
    NewRelic::Plugin::Config.stubs(:config).returns(TestConfig.new(@newrelic))
    NewRelic::Plugin::Run.new()
  end
end
