require 'rubygems'

##
# RailsRemoteControl allows you to monitor individual Rails processes and
# adjust the log level of a process for debugging purposes.  (For example, to
# turn on partial rendering times for a single process.)
#
# = Installation
#
# First, start a RailsRemoteControl::Server when your Rails process starts up
# by adding these two lines to config/environment.rb:
#
#   require 'rails_remote_control/server'
#   RailsRemoteControl::Server.run 'my_rails_app'
#
# Next, add <tt>include RailsRemoteControl::Process</tt> in Application
# controller:
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
# = Usage
#
# Then start up a RingServer where you want to monitor and control your remote
# processes:
#
#   $ ring_server -d
#
# You can start the RingServer up before or after the Rails app.  The rails
# processes will automatically connect soon after it starts.
#
# Then start up the RailsRemoteControl::HTTPServer so you can control your
# processes:
#
#   $ rails_remote_control -d
#
# Then connect with your web browser to port 8000 on that machine.
#
# = It Doesn't Work
#
# * Do you have forward and reverse DNS set up for all your machines?
#     $ host `hostname`
#     ziz.jijo.segment7.net has address 10.101.28.1
#     $ host 10.101.28.1
#     1.28.101.10.in-addr.arpa domain name pointer ziz.jijo.segment7.net.
#   Both forward and reverse addresses need to match here.
# * Have you disabled IPv6 or set up RDNS for your IPv6 hosts?

module RailsRemoteControl

  ##
  # The version of RailsRemoteControl you have installed.

  VERSION = '1.0.0'

end

