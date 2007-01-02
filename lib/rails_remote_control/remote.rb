require 'rails_remote_control'
require 'ringy_dingy/ring_server'
require 'rails_remote_control/server'

##
# RailsRemoteControl process locater.

class RailsRemoteControl::Remote

  ##
  # Remote server struct

  Server = Struct.new :host, :pid, :remote_server

  ##
  # Looks for services on the RingServer and returns an Array of discovered
  # Rails processes.

  def services
    services = RingyDingy::RingServer.list_services
    return [] if services.empty?

    services = RingyDingy::RingServer.list_services.values.first.uniq

    rrc_servers = services.select do |_, klass,|
      klass == RailsRemoteControl::Server::RINGY_DINGY_SERVICE
    end

    rrc_servers.map do |_, _, server, name|
      host, pid, = name.split '_', 3
      Server.new host, pid.to_i, server
    end
  end

end

require 'rails_remote_control/remote/server'

