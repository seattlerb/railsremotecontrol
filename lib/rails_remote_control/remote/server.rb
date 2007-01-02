require 'rails_remote_control/remote'

##
# RailsRemoteControl remote server convenience wrapper.

class RailsRemoteControl::Remote::Server

  ##
  # Dispatch other messages to the remote server.

  def method_missing(*args, &block)
    remote_server.send(*args, &block)
  end

end

