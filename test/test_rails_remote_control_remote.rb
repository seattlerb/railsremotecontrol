$TESTING = true

require 'test/unit'
require 'rails_remote_control/remote'
require 'test/util'

class TestRailsRemoteControlRemote < Test::Unit::TestCase

  RRCR = RailsRemoteControl::Remote

  def setup
    @remote = RRCR.new
    RingyDingy::RingServer.default = RingyDingy::RingServer::DEFAULT
  end

  def teardown
    RingyDingy::RingServer.default = RingyDingy::RingServer::DEFAULT
  end

  def test_services
    RingyDingy::RingServer.default = RingyDingy::RingServer::DEFAULT

    expected = [
      RRCR::Server.new('cutie', 1000,
                       RailsRemoteControl::Server.new('43places')),
      RRCR::Server.new('cutie', 1001,
                       RailsRemoteControl::Server.new('43places')),
      RRCR::Server.new('hal', 61000,
                       RailsRemoteControl::Server.new('43things')),
    ]

    assert_equal expected, @remote.services
  end

  def test_services_no_services
    RingyDingy::RingServer.default = {}

    assert_equal [], @remote.services
  end

end

