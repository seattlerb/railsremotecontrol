$TESTING = true

require 'test/unit'
require 'rails_remote_control/http_server'

class TestRailsRemoteControlHTTPServer < Test::Unit::TestCase
  
  def test_self_process_args
    options = RailsRemoteControl::HTTPServer.process_args %w[-d -p 80]

    expected = { :Daemon => true, :Port => 80 }
    assert_equal expected, options
  end

end

