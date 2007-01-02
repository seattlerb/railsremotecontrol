require 'test/unit'
require 'rails_remote_control/server'
require 'rails_remote_control/remote/server'

class TestRailsRemoteControlRemoteServer < Test::Unit::TestCase

  def setup
    @server = RailsRemoteControl::Server.new 'name'
    @remote_server = RailsRemoteControl::Remote::Server.new 'localhost', $$, @server
  end

  def test_method_missing
    assert_equal 0, @remote_server.requests_handled
  end

end

