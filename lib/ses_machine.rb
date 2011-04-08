# encoding: utf-8

require 'rubygems'

gem 'rails', '~> 2.3.8'
gem 'activesupport', '~> 2.3.8'
gem 'actionmailer', '~> 2.3.8'

require 'singleton'
require 'mongo'
require 'action_mailer'
require 'action_mailer/version'
require 'dkim'
require 'mail'
require 'aws/ses'
require 'will_paginate'
require 'ses_machine/bounce'
require 'ses_machine/config'
require 'ses_machine/core_ext'
require 'ses_machine/db'
require 'ses_machine/errors'
require 'ses_machine/mailer'
require 'ses_machine/routing'



%w{ models controllers helpers}.each do |dir|
  path = File.join(File.dirname(__FILE__), '..', 'app', dir)
  $LOAD_PATH << path
  ActiveSupport::Dependencies.load_paths << path
  ActiveSupport::Dependencies.load_once_paths.delete(path)
  ActionController::Base.append_view_path(File.join(File.dirname(__FILE__), '..', 'app', 'views'))

end


module SesMachine #:nodoc

  module Hooks; end

  class << self

    # Sets the SesMachine configuration options. Best used by passing a block.
    #
    # Example:
    #
    #   SesMachine.configure do |config|
    #     config.use_dkim = true
    #     config.dkim_domain = 'example.com'
    #     config.dkim_selector = 'ses'
    #     config.dkim_private_key = '/path/to/private/key'
    #   end
    #
    # Returns:
    #
    # The SesMachine +Config+ singleton instance.
    def configure
      SesMachine::Config.instance
      config = SesMachine::Config.instance
      block_given? ? yield(config) : config
    end
    alias :config :configure
  end

  # Take all the public instance methods from the Config singleton and allow
  # them to be accessed through the SesMachine module directly.
  #
  # Example:
  #
  # <tt>SesMachine.database = Mongo::Connection.new.db("test")</tt>
  SesMachine::Config.public_instance_methods(false).each do |name|
    (class << self; self; end).class_eval <<-EOT
      def #{name}(*args)
        configure.send("#{name}", *args)
      end
    EOT
  end
end

ENV['RAILS_ENV'] ||= Rails.env || 'development'
ENV['RAILS_ROOT'] ||= Rails.root || File.dirname(__FILE__) + '/../../../..'

SesMachine.config.load unless ENV['RAILS_ENV'].eql?('test')
