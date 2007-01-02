# -*- ruby -*-

require 'rubygems'
require 'hoe'

$:.unshift 'lib'
require 'rails_remote_control'

DEV_DOC_PATH = "Tools/RailsRemoteControl"

hoe = Hoe.new('RailsRemoteControl', RailsRemoteControl::VERSION) do |p|
  p.summary = 'FIX'
  p.description = p.paragraphs_of('README.txt', 2).join("\n\n")
  p.author = 'Eric Hodel'
  p.email = 'drbrain@segment7.net'
  p.url = "http://dev.robotcoop.com/#{DEV_DOC_PATH}"
  p.rubyforge_name = 'seattlerb'
  p.changes = File.read('History.txt').scan(/\A(=.*?)(=|\Z)/m).first.first

  p.extra_deps << ['RingyDingy', '>= 1.2.0']
  p.extra_deps << ['ZenTest', '>= 3.4.2']
end

# vim: syntax=Ruby
