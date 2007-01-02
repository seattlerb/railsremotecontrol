require 'rubygems'

##
# RailsRemoteControl allows you to monitor individual Rails processes and
# adjust the log level of a process for debugging purposes.  (For example, to
# turn on partial rendering times for a single process.)
#
# = Usage
#
# First, start a RailsRemoteControl::Server when your Rails process starts up
# by adding these two lines to config/environment.rb:
#
#   require 'rails_remote_control/server'
#   RailsRemoteControl::Server.run 'my_rails_app'
#
# Next, add include RailsRemoteControl::Process in Application controller:
#
#   require 'rails_remote_control/process'
#   
#   class ApplicationController < ActionController::Base
#   
#     include RailsRemoteControl::Process
#   
#     # ...
#   
#   end
#
# Then start up a RingServer where you want to monitor and control your remote
# processes:
#
#   $ ring_server -d
#
# Then start up the RailsRemoteControl::HTTPServer so you can control your
# processes:
#
#   $ rails_remote_control -d
#
# Then connect with your web browser to port 8000 on that machine.

module RailsRemoteControl

  ##
  # The version of RailsRemoteControl you have installed.

  VERSION = '1.0.0'

end

