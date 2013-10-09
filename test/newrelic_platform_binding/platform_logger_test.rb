require 'test_helper'

class PlatformLoggerTest < Minitest::Test

  def setup
    @log = NewRelic::PlatformLogger.instance_variable_get(:@log)
  end

  def test_debug_calls_log_debug
    @log.expects(:debug).with('test')
    NewRelic::PlatformLogger.debug('test')
  end

  def test_info_calls_log_info
    @log.expects(:info).with('test')
    NewRelic::PlatformLogger.info('test')
  end

  def test_warn_calls_log_warn
    @log.expects(:warn).with('test')
    NewRelic::PlatformLogger.warn('test')
  end

  def test_error_calls_log_error
    @log.expects(:error).with('test')
    NewRelic::PlatformLogger.error('test')
  end

  def test_fatal_calls_log_fatal
    @log.expects(:fatal).with('test')
    NewRelic::PlatformLogger.fatal('test')
  end
end
