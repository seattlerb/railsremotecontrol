$TESTING = false unless defined? $TESTING

require 'webrick/httpservlet/abstract'
require 'webrick/httpstatus'
require 'rails_remote_control'
require 'rails_remote_control/remote'
require 'logger'

##
# RailsRemoteControl WEBrick servlet for process monitoring and control.

class RailsRemoteControl::Servlet < WEBrick::HTTPServlet::AbstractServlet

  logger_levels = Logger::Severity.constants.map do |c|
    [Logger::Severity.const_get(c), c]
  end

  ##
  # Map Logger's log levels to friendly names

  LOGGER_LEVELS = logger_levels.sort_by { |l,n| l }

  @services = nil
  @services_thread = nil

  ##
  # Accessor for services cache

  def self.services
    @services
  end

  ##
  # Fetching a list of services will block for five seconds, so do that in a
  # separate thread and cache the results.  This method is called at require
  # time.

  def self.start_services_thread
    @services_thread = Thread.start do
      remote = RailsRemoteControl::Remote.new

      loop do
        @services = remote.services
        sleep 10
      end
    end

    sleep 0.1 while @services.nil?
  end

  start_services_thread unless $TESTING

  def do_GET(req, res) # :nodoc:
    case req.request_uri.request_uri
    when '/' then
      res.body = list
    when %r%\A/server/([^/]+)/(\d+)\Z%
      res.body = server $1, $2.to_i
    else
      super
    end
  end

  def do_POST(req, res) # :nodoc:
    case req.request_uri.request_uri
    when %r%\A/server/([^/]+)/(\d+)/log_level\Z%
      host, pid = $1, $2.to_i
      req.body =~ /log_level=(\d+)/
      level = Integer($1) rescue nil
      res.body = set_log_level host, pid, level
    else
      super
    end
  end

  ##
  # Displays a list of rails processes available for remote control.

  def list
    out = "<title>No Processes</title>\n"
    out << "<h1>No Processes</h1>\n"
    out << "<p>Did you start ring_server?"
    out << "<p>Did you start rails_remote_control?\n"
    out << "<p>Did you set up your Rails application for monitoring?\n"
    return out if services.nil?

    out = []
    out << "<title>Active Processes</title>"
    out << "<h1>Active Processes</h1>"
    out << nil
    out << '<table>'
    out << '<tr><th colspan=2>&nbsp;<th colspan=2>Requests<th>&nbsp;'
    out << '<tr><th>Host<th>Process<th>Attempted<th>Handled<th>Log Level'

    services.each do |server|
      row = server_row server
      out << row if row
    end

    out << '</table>' << nil

    out.join "\n"
  end

  ##
  # Displays information about process +pid+ on +host+.

  def server(host, pid)
    server = get_server host, pid

    out = []
    out << "<title>#{host} pid #{pid}</title>"
    out << "<h1>#{host} pid #{pid}</h1>"
    out << nil

    out << '<a href="/">Active Processes</a>'
    out << nil

    out << '<table>'
    out << "<tr><th>Log Level<td>#{server.log_level}"
    out << "<tr><th>Requests Attempted<td>#{server.requests_attempted}"
    out << "<tr><th>Requests Handled<td>#{server.requests_handled}"
    out << '</table>' << nil

    out << "<form method=\"post\" action=\"/server/#{host}/#{pid}/log_level\">"
    out << '<div>'
    out << '<label for="log_level">Change Log Level</label>'
    out << '<select id="log_level" name="log_level">'

    LOGGER_LEVELS.each do |level, name|
      selected = server.log_level == level ? ' selected' : nil
      out << "<option#{selected} value=\"#{level}\">#{name}</option>"
    end

    out << '</select>'
    out << '<input type="submit" value="Change">'
    out << '</div>' << '</form>' << nil

    unless server.requests.empty? then
      out << '<table>'
      out << "<tr><th>Action<th>Requests Handled"
      server.requests.sort_by { |a,c| -c }.each do |action, count|
        out << "<tr><td>#{action}<td>#{count}"
      end
      out << '</table>' << nil
    end

    out.join "\n"
  rescue DRb::DRbConnError
    raise WEBrick::HTTPStatus::NotFound, "#{host}:#{pid} is no longer reachable"
  rescue NoMethodError
    raise WEBrick::HTTPStatus::NotFound, "#{host}:#{pid} has gone away"
  end

  def service(req, res) # :nodoc:
    @req = req
    @res = res
    @res.content_type = 'text/html'
    super
  end

  ##
  # Services accessor

  def services
    self.class.services
  end

  ##
  # Construct a table row with information on +server+.

  def server_row(server)
    tr = []
    tr << "<td>#{server.host}"
    tr << "<td><a href=\"/server/#{server.host}/#{server.pid}\">#{server.pid}</a>"
    tr << "<td>#{server.requests_attempted}"
    tr << "<td>#{server.requests_handled}"
    tr << "<td>#{server.log_level}"

    "<tr>#{tr.join}"

  rescue DRb::DRbConnError
    nil
  end

  ##
  # Sets the log level for process +pid+ on +host+ to +level+.

  def set_log_level(host, pid, level)
    server = get_server host, pid
    server.log_level = level
    @res.set_redirect WEBrick::HTTPStatus::SeeOther, "/server/#{host}/#{pid}"
  rescue DRb::DRbConnError
    raise WEBrick::HTTPStatus::NotFound, "#{host}:#{pid} is no longer reachable"
  rescue NoMethodError
    raise WEBrick::HTTPStatus::NotFound, "#{host}:#{pid} has gone away"
  end

  ##
  # Retrieves the server for process +pid+ on +host+.

  def get_server(host, pid)
    services.find { |s| s.host == host and s.pid == pid }
  end

end

