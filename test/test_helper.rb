# -*- encoding : utf-8 -*-

ENV['RAILS_ENV'] = 'test'
ENV['RAILS_ROOT'] = File.join(File.dirname(__FILE__), 'fixtures')

require 'test/unit'
require File.join(File.dirname(__FILE__), '..', 'lib', 'ses_machine')
