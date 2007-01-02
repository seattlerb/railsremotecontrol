require 'test/unit'
require 'rubygems'
require 'test/zentest_assertions'
require 'test/util'

require 'rails_remote_control/server'

class RailsRemoteControl::Server
  attr_reader :ringy_dingy
  public :host, :name, :pid
end

class TestRailsRemoteControlServer < Test::Unit::TestCase

  RRCS = RailsRemoteControl::Server

  def setup
    @name = 'RailsRemoteControl::Server test'
    @server = RRCS.new @name
  end

  def test_equal
    server = RRCS.new @name

    assert_equal server, @server
  end

  def test_host
    assert_equal Socket.gethostname, @server.host
  end

  def test_initialize
    deny_nil @server.ringy_dingy
    assert_equal "#{Socket.gethostname.downcase}_#{$PID}_#{@name}",
                 @server.ringy_dingy.identifier
  end

  def test_log_level
    assert_equal Logger::DEBUG, @server.log_level
  end

  def test_log_level_equals
    level = @server.log_level
    @server.log_level = Logger::FATAL
    assert_equal Logger::FATAL, @server.log_level
    assert_equal Logger::FATAL, RAILS_DEFAULT_LOGGER.level
  ensure
    @server.log_level = level
  end

  def test_name
    assert_equal @name, @server.name
  end

  def test_pid
    assert_equal $$, @server.pid
  end

  def test_requests
    assert_equal Hash.new, @server.requests
  end

  def test_requests_attempted
    assert_equal 0, @server.requests_attempted
  end

  def test_requests_handled
    assert_equal 0, @server.requests_handled
  end

  def test_run
    assert_nil @server.ringy_dingy.thread
    @server.run
    deny_nil @server.ringy_dingy.thread
  end

  alias deny_nil assert_not_nil # HACK ZenTest 3.4.2

end

