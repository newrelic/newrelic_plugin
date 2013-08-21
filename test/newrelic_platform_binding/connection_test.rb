require 'test_helper'
require 'logger'

class ConnectionTest < Minitest::Test

  def setup
    @context = NewRelic::Binding::Context.new('license_key')
    @connection = NewRelic::Binding::Connection.new(@context)
    NewRelic::Logger.log_level = ::Logger::FATAL
  end

  def test_deliver_successful
    FakeWeb.register_uri(:post, "https://platform-api.newrelic.com/platform/v1/metrics", :body => '{"status":"ok"}', :status => [200, "Success"])
    ::Logger.expects(:info).never
    assert_equal true, @connection.send_request('data')
  end

  def test_deliver_error_codes
    FakeWeb.register_uri(:post, "https://platform-api.newrelic.com/platform/v1/metrics", :body => '{"error":"Missing metric data"}', :status => [200, "Success"])
    NewRelic::Logger.expects(:error).with('FAILED[200] <https://platform-api.newrelic.com/platform/v1/metrics>: Missing metric data')
    assert_equal false, @connection.send_request('data')
  end

  def test_deliver_disabled_by_new_relic
    FakeWeb.register_uri(:post, "https://platform-api.newrelic.com/platform/v1/metrics", :body => 'DISABLE_NEW_RELIC', :status => [403, 'Unauthorized'])
    NewRelic::Logger.expects(:fatal).with("Agent has been disabled remotely by New Relic")
    NewRelic::Binding::Connection.any_instance.expects(:abort)
    @connection.send_request('data')
  end

  def test_deliver_no_response
    Net::HTTP.any_instance.expects(:request).returns(nil)
    NewRelic::Logger.expects(:error).with("FAILED: No response")
    assert_equal false, @connection.send_request('data')
  end

  def test_deliver_no_data_returned
    FakeWeb.register_uri(:post, "https://platform-api.newrelic.com/platform/v1/metrics", :body => '', :status => [204, "No Content"])
    NewRelic::Logger.expects(:error).with('FAILED[204] <https://platform-api.newrelic.com/platform/v1/metrics>: no data returned')
    assert_equal false, @connection.send_request('data')
  end

  def test_deliver_non_json_response_body_unexpected_response_code
    FakeWeb.register_uri(:post, "https://platform-api.newrelic.com/platform/v1/metrics", :body => 'test', :status => [203, "Non-Authoritative Information"])
    JSON::ParserError.any_instance.stubs(:message => 'parse error')
    NewRelic::Logger.expects(:error).with("FAILED[203] <https://platform-api.newrelic.com/platform/v1/metrics>: Could not parse response: parse error")
    assert_equal false, @connection.send_request('data')
  end

  def test_deliver_non_json_response_body_success_response_code
    FakeWeb.register_uri(:post, "https://platform-api.newrelic.com/platform/v1/metrics", :body => 'test', :status => [200, "Success"])
    JSON::ParserError.any_instance.stubs(:message => 'parse error')
    NewRelic::Logger.expects(:error).with("FAILED[200] <https://platform-api.newrelic.com/platform/v1/metrics>: Could not parse response: parse error")
    assert_equal false, @connection.send_request('data')
  end

  def test_deliver_service_unavailable
    FakeWeb.register_uri(:post, "https://platform-api.newrelic.com/platform/v1/metrics", :body => 'test', :status => [503, "Service Unavailable"])
    NewRelic::Logger.expects(:warn).with("Collector temporarily unavailable. Continuing.")
    assert_equal false, @connection.send_request('data')
  end

end
