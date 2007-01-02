require 'English'
require 'logger'
require 'rubygems'
require 'ringy_dingy'
require 'rails_remote_control'
require 'rails_remote_control/process'

##
# RailsRemoteControl server process.  Run this from config/environment.rb to
# allow RailsRemoteControl::Remote to find the Rails processes you are
# running.
#
# = Example
#
# Add the following lines to config/environment.rb for your application:
#
#   require 'rails_remote_control/server'
#   RailsRemoteControl::Server.run 'my_rails_app'

class RailsRemoteControl::Server

  ##
  # Service name for RingyDingy

  RINGY_DINGY_SERVICE = name.delete(':').intern

  ##
  # Run as +name+.

  def self.run(name = nil)
    new(name).run
  end

  ##
  # Creates a new RailsRemoteControl server as +name+.
  #
  # Use +name+ to disambiguate multiple Rails applications.

  def initialize(name)
    @name = name
    @ringy_dingy = RingyDingy.new self, RINGY_DINGY_SERVICE, name
    @pid = $PID
    @host = Socket.gethostname
  end

  ##
  # Start running

  def run
    @ringy_dingy.run
  end

  ##
  # Returns the current log level of the default logger for this Rails
  # process.

  def log_level
    RAILS_DEFAULT_LOGGER.level
  end

  ##
  # Sets the current log level of the default logger for this Rails process to
  # +level+.

  def log_level=(level)
    RAILS_DEFAULT_LOGGER.level = level
  end

  ##
  # A Hash mapping action names to number of requests handled.
  #
  # See RailsRemoteControl::Process#requests.

  def requests
    RailsRemoteControl::Process.requests
  end

  ##
  # Number of requests attempted by this Rails process.

  def requests_attempted
    RailsRemoteControl::Process.requests_attempted
  end

  ##
  # Number of requests handled by this Rails process.  (If this number is
  # different from #requests_attempted something bad happened, check your
  # logs.)

  def requests_handled
    RailsRemoteControl::Process.requests_handled
  end

  def ==(other) # :nodoc:
    self.class === other and other.name == self.name and
      other.host == self.host and other.pid == self.pid
  end

  protected

  ##
  # Name of this Rails process.

  attr_reader :name

  ##
  # Host this Rails process is running on.

  attr_reader :host

  ##
  # Process id for this Rails process.

  attr_reader :pid

end

