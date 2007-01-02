require 'rails_remote_control'
require 'rails_remote_control/servlet'
require 'webrick/httpserver'

##
# RailsRemoteControl HTTP server.
#
# This provides the console for monitoring and modifying your Rails processes.
# By default it runs on port 8000.

class RailsRemoteControl::HTTPServer < WEBrick::HTTPServer

  @server = nil

  ##
  # Processes ARGV style +args+ into an options Hash.

  def self.process_args(args)
    options = {}
    options[:Daemon] = false
    options[:Port] = 8000

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: #{name} [options]"
      opts.on("-p", "--port=PORT",
              "RailsRemoteControl HTTP Server Port", Integer) do |port|
        options[:Port] = port
      end

      opts.on("-d", "--daemon",
              "Run as a daemon process") do |daemon|
        options[:Daemon] = true
      end
    end

    opts.parse! args

    return options
  end

  ##
  # Start and run a RailsRemoteControl HTTP server, depending upon +args+.

  def self.run(args = ARGV)
    options = process_args args

    if options[:Daemon] then
      WEBrick::Daemon.start
    end

    @server = new :Port => options[:Port]
    @server.mount '/', RailsRemoteControl::Servlet

    trap 'INT' do stop end
    trap 'KILL' do stop end

    @server.start
  end

  ##
  # Stop the RailsRemoteControl HTTP server.

  def self.stop
    @server.stop
  end

end

