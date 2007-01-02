require 'logger'
require 'rubygems'
require 'test/zentest_assertions'
require 'ringy_dingy/ring_server'
require 'rails_remote_control/server'

RAILS_DEFAULT_LOGGER = Logger.new '/dev/null'

class RingyDingy::RingServer

  @s1 = RailsRemoteControl::Server.new '43places'
  @s2 = RailsRemoteControl::Server.new '43places'
  @s3 = RailsRemoteControl::Server.new '43things'

  DEFAULT = {
    'druby://localhost:10000' => [
      [:name, RailsRemoteControl::Server::RINGY_DINGY_SERVICE, @s1,
        'cutie_1000_43places'],
      [:name, RailsRemoteControl::Server::RINGY_DINGY_SERVICE, @s2,
        'cutie_1001_43places'],
      [:name, RailsRemoteControl::Server::RINGY_DINGY_SERVICE, @s3,
        'hal_61000_43places'],
    ]
  }

  def self.default=(default)
    @default = default
  end

  def self.list_services
    @default
  end

end

