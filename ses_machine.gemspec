# -*- encoding: utf-8 -*-

require File.expand_path('../lib/ses_machine/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'ses_machine'
  s.version     = SesMachine::VERSION::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Kirill Nikitin']
  s.email       = ['locke23rus@gmail.com']
  s.homepage    = 'http://rubygems.org/gems/ses_machine'
  s.summary     = 'SES Machine'
  s.description = 'SES Machine description'
  s.license     = 'MIT'

  s.required_rubygems_version = '>= 1.3.6'

  s.add_dependency 'mail', '>= 2.4.4'
  s.add_dependency 'aws-ses', '>= 0.4.4'
  s.add_dependency 'rubydkim', '>= 0.3.1'
  s.add_dependency 'mongo', '>= 1.9.1'
  s.add_dependency 'bson', '>= 1.9.1'
  s.add_dependency 'bson_ext', '>= 1.9.1'
  s.add_dependency 'will_paginate', '>= 3.0.4'

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- test/*`.split("\n")
  s.require_path = 'lib'
end
