require 'test_helper'

class ConfigTest < Minitest::Test

  def setup
    @endpoint = NewRelic::Binding::Config.endpoint
    @ssl_host_verification = NewRelic::Binding::Config.ssl_host_verification
    @uri = NewRelic::Binding::Config.uri
    @poll_cycle_period = NewRelic::Binding::Config.poll_cycle_period
  end

  def teardown
    NewRelic::Binding::Config.endpoint = @endpoint
    NewRelic::Binding::Config.ssl_host_verification = @ssl_host_verification
    NewRelic::Binding::Config.uri = @uri
    NewRelic::Binding::Config.poll_cycle_period = @poll_cycle_period
  end

  def test_endpoint_default
    assert_equal 'https://platform-api.newrelic.com', NewRelic::Binding::Config.endpoint
  end

  def test_set_endpoint
    new_endpoint = 'http://example.com'
    NewRelic::Binding::Config.endpoint = new_endpoint
    assert_equal new_endpoint, NewRelic::Binding::Config.endpoint
  end

  def test_uri_default
    assert_equal '/platform/v1/metrics', NewRelic::Binding::Config.uri
  end

  def test_set_uri
    new_uri = '/foo'
    NewRelic::Binding::Config.uri = new_uri
    assert_equal new_uri, NewRelic::Binding::Config.uri
  end

  def test_ssl_host_verification_default
    assert_equal true, NewRelic::Binding::Config.ssl_host_verification
  end

  def test_set_ssl_host_verification
    new_ssl_host_verification = false
    NewRelic::Binding::Config.ssl_host_verification = new_ssl_host_verification
    assert_equal new_ssl_host_verification, NewRelic::Binding::Config.ssl_host_verification
  end

  def test_poll_cycle_period
    assert_equal 60, NewRelic::Binding::Config.poll_cycle_period
  end

  def test_set_poll_cycle_period
    new_poll_cycle_period = 120
    NewRelic::Binding::Config.poll_cycle_period = new_poll_cycle_period
    assert_equal new_poll_cycle_period, NewRelic::Binding::Config.poll_cycle_period
  end
end
