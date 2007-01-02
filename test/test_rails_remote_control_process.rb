require 'test/unit'

module ActionController; end
class ActionController::Base

  attr_reader :action_name

  def self.process(req, res)
    new.process req, res
  end

  def process(req, res)
    params = req.parameters
    @action_name = params['action']
  end

  def controller_class_name
    self.class.name.split('::').last
  end

end

require 'rails_remote_control/process'

class ApplicationController < ActionController::Base
  include RailsRemoteControl::Process
end

class MyController < ApplicationController

  def index
  end

  def show
  end

end

module Nested; end
class Nested::MyController < ApplicationController

  def index
  end

  def show
  end

end

module RailsRemoteControl
  def Process.reset
    @requests_handled = 0
    @requests_attempted = 0
    @requests.clear
  end
end

class TestRailsRemoteControlProcess < Test::Unit::TestCase

  RRCP = RailsRemoteControl::Process

  FakeRequest = Struct.new :parameters

  def setup
    @request = FakeRequest.new
    @request.parameters = { 'action' => 'index' }
  end

  def teardown
    RRCP.reset
  end

  def test_process
    MyController.new.process @request, nil

    assert_equal 1, RRCP.requests_handled
    assert_equal 1, RRCP.requests_attempted

    expected = { 'MyController#index' => 1 }
    assert_equal expected, RRCP.requests
  end

  def test_process_nested
    Nested::MyController.new.process @request, nil

    assert_equal 1, RRCP.requests_handled

    expected = { 'Nested::MyController#index' => 1 }
    assert_equal expected, RRCP.requests
  end

end

