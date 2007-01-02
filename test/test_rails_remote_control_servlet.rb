$TESTING = true

require 'test/unit'
require 'stringio'
require 'test/util'

require 'rails_remote_control/servlet'

require 'webrick/httprequest'
require 'webrick/httpresponse'

class FakeWEBrickServer
  def [](arg); end
end

class RailsRemoteControl::Servlet
  def self.services=(services)
    @services = services
  end
end

class TestRailsRemoteControlServlet < Test::Unit::TestCase

  RRCRS = RailsRemoteControl::Remote::Server
  RRCS = RailsRemoteControl::Servlet

  def setup
    @server = RailsRemoteControl::Server.new 'name'
    @dead_server = RailsRemoteControl::Server.new 'name'
    def @dead_server.requests_attempted() raise DRb::DRbConnError; end
    RRCS.services = [
      RRCRS.new('cutie', 1000, @server),
      RRCRS.new('cutie', 1001, @server),
      RRCRS.new('hal', 61000, @server),
      RRCRS.new('hal', 61001, @dead_server),
    ]

    @http_server = FakeWEBrickServer.new
    @servlet = RRCS.new @http_server
    @config = { :Logger => nil, :HTTPVersion => '1.0' }
  end

  def teardown
    RailsRemoteControl::Server.new(nil).requests.clear
  end

  def test_do_GET_list
    req = WEBrick::HTTPRequest.new @config
    req.parse StringIO.new("GET / HTTP/1.0\r\n\r\n")
    res = WEBrick::HTTPResponse.new @config

    def @servlet.list
      return 'list'
    end

    @servlet.service req, res

    assert_equal 'list', res.body
  end

  def test_do_GET_server
    req = WEBrick::HTTPRequest.new @config
    req.parse StringIO.new("GET /server/cutie/1000 HTTP/1.0\r\n\r\n")
    res = WEBrick::HTTPResponse.new @config

    def @servlet.server(host, pid)
      return "server #{host} #{pid}"
    end

    @servlet.service req, res

    assert_equal 'server cutie 1000', res.body
  end

  def test_do_GET_server_with_dot
    req = WEBrick::HTTPRequest.new @config
    req.parse StringIO.new("GET /server/kaa.local/1000 HTTP/1.0\r\n\r\n")
    res = WEBrick::HTTPResponse.new @config

    def @servlet.server(host, pid)
      return "server %p %p" % [host, pid]
    end

    @servlet.service req, res

    assert_equal 'server "kaa.local" 1000', res.body
  end

  def test_do_POST_server_log_level
    req = WEBrick::HTTPRequest.new @config
    req.parse StringIO.new("POST /server/cutie/1000/log_level HTTP/1.0\r\nContent-Length: 11\r\n\r\nlog_level=5")
    res = WEBrick::HTTPResponse.new @config

    def @servlet.set_log_level(host, pid, level)
      return "server #{host} #{pid} #{level}"
    end

    @servlet.service req, res

    assert_equal 'server cutie 1000 5', res.body
  end

  def test_list
    expected = <<-EOF
<title>Active Processes</title>
<h1>Active Processes</h1>

<table>
<tr><th colspan=2>&nbsp;<th colspan=2>Requests<th>&nbsp;
<tr><th>Host<th>Process<th>Attempted<th>Handled<th>Log Level
<tr><td>cutie<td><a href="/server/cutie/1000">1000</a><td>0<td>0<td>0
<tr><td>cutie<td><a href="/server/cutie/1001">1001</a><td>0<td>0<td>0
<tr><td>hal<td><a href="/server/hal/61000">61000</a><td>0<td>0<td>0
</table>
    EOF

    assert_equal expected, @servlet.list
  end

  def test_server
    server = RailsRemoteControl::Server.new 'name'
    server.requests['RouteController#index'] = 2
    server.requests['RouteController#route_markers'] = 1
    RRCS.services = [RRCRS.new('cutie', 1000, server)]

    expected = <<-EOF
<title>cutie pid 1000</title>
<h1>cutie pid 1000</h1>

<a href="/">Active Processes</a>

<table>
<tr><th>Log Level<td>0
<tr><th>Requests Attempted<td>0
<tr><th>Requests Handled<td>0
</table>

<form method="post" action="/server/cutie/1000/log_level">
<div>
<label for="log_level">Change Log Level</label>
<select id="log_level" name="log_level">
<option selected value="0">DEBUG</option>
<option value="1">INFO</option>
<option value="2">WARN</option>
<option value="3">ERROR</option>
<option value="4">FATAL</option>
<option value="5">UNKNOWN</option>
</select>
<input type="submit" value="Change">
</div>
</form>

<table>
<tr><th>Action<th>Requests Handled
<tr><td>RouteController#index<td>2
<tr><td>RouteController#route_markers<td>1
</table>
    EOF

    assert_equal expected, @servlet.server('cutie', 1000)
  end

  def test_server_dead
    e = assert_raise WEBrick::HTTPStatus::NotFound do
      @servlet.server 'hal', 61001
    end

    assert_equal 'hal:61001 is no longer reachable', e.message
  end

  def test_server_gone
    util_test_gone :server
  end

  def test_server_no_requests
    expected = <<-EOF
<title>cutie pid 1001</title>
<h1>cutie pid 1001</h1>

<a href="/">Active Processes</a>

<table>
<tr><th>Log Level<td>0
<tr><th>Requests Attempted<td>0
<tr><th>Requests Handled<td>0
</table>

<form method="post" action="/server/cutie/1001/log_level">
<div>
<label for="log_level">Change Log Level</label>
<select id="log_level" name="log_level">
<option selected value="0">DEBUG</option>
<option value="1">INFO</option>
<option value="2">WARN</option>
<option value="3">ERROR</option>
<option value="4">FATAL</option>
<option value="5">UNKNOWN</option>
</select>
<input type="submit" value="Change">
</div>
</form>
    EOF

    assert_equal expected, @servlet.server('cutie', 1001)
  end

  def test_set_log_level
    @servlet.instance_variable_set :@res, WEBrick::HTTPResponse.new(@config)

    assert_raise WEBrick::HTTPStatus::SeeOther do
      @servlet.set_log_level 'cutie', 1000, 5
    end

    assert_equal 5, @server.log_level
  end

  def test_set_log_level_no_server
    util_test_gone :set_log_level, 5
  end

  def util_test_gone(action, *args)
    e = assert_raise WEBrick::HTTPStatus::NotFound do
      @servlet.send(action, 'none', 0, *args)
    end

    assert_equal 'none:0 has gone away', e.message
  end

end

