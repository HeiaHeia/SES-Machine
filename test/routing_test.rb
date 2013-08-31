# -*- encoding : utf-8 -*-

require 'test_helper'

class RoutingTest < ActionController::TestCase
  def setup
    ActionController::Routing::Routes.draw do |map|
      map.ses_machine
    end
  end

  test 'map index ses machine' do
    assert_recognizes({:controller => 'ses_machine', :action => 'index'}, {:path => 'ses_machine', :method => :get})
    assert_recognizes({:controller => 'ses_machine', :action => 'activity'}, {:path => 'ses_machine/activity', :method => :get})
    assert_recognizes({:controller => 'ses_machine', :action => 'show_message', :id => '1'}, {:path => 'ses_machine/message/1', :method => :get})
  end
end
