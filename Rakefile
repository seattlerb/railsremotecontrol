# -*- ruby -*-

require 'rubygems'
require 'hoe'

$:.unshift 'lib'
require 'rails_remote_control'

hoe = Hoe.new('RailsRemoteControl', RailsRemoteControl::VERSION) do |p|
  p.summary = 'Alter Rails log levels and monitor processes without restarts'
  p.description = File.read('README.txt').scan(/== DESCRIPTION:(.*?)==/m).first.first.strip
  p.author = 'Eric Hodel'
  p.email = 'drbrain@segment7.net'
  p.rubyforge_name = 'seattlerb'
  p.url = 'http://seattlerb.rubyforge.org/RailsRemoteControl'
  p.changes = File.read('History.txt').scan(/\A(=.*?)(=|\Z)/m).first.first

  p.extra_deps << ['RingyDingy', '>= 1.2.0']
  p.extra_deps << ['ZenTest', '>= 3.4.2']
  p.extra_deps << ['actionpack', '>= 1.12.5']
end

# vim: syntax=Ruby
