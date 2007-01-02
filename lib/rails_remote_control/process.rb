require 'rails_remote_control'

##
# RailsRemoteControl::Process records statistics of a running Rails process.
#
# Include it in your ApplicationController to record these statistics:
#
#   require 'rails_remote_control/process'
#   
#   class ApplicationController < ActionController::Base
#   
#     include RailsRemoteControl::Process
#   
#   end

module RailsRemoteControl::Process

  @requests_attempted = 0
  @requests_handled = 0

  @requests = Hash.new { |h,full_action_name| h[full_action_name] = 0 }

  class << self

    ##
    # Hash mapping action names to times handled.

    attr_reader :requests

    ##
    # Requests attempted

    attr_accessor :requests_attempted

    ##
    # Requests successfully handled

    attr_accessor :requests_handled

  end

  ##
  # ActionController::Base#process wrapper that records statistics for actions
  # handled by this Rails process.

  def process(req, res)
    RailsRemoteControl::Process.requests_attempted += 1

    result = super

    RailsRemoteControl::Process.requests_handled += 1
    full_action_name = "#{self.class.name}##{action_name}"
    RailsRemoteControl::Process.requests[full_action_name] += 1

    return result
  end

end

