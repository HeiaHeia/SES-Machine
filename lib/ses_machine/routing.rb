# encoding: utf-8

module SesMachine #:nodoc:
  module Routing #:nodoc:
    module MapperExtensions
      def ses_machine
        @set.add_named_route("ses_machine", "ses_machine", {:controller => "ses_machine", :action => "index"})
        @set.add_named_route("ses_machine_activity", "ses_machine/activity", {:controller => "ses_machine", :action => "activity"})
        @set.add_named_route("ses_machine_message", "ses_machine/message/:id", {:controller => "ses_machine", :action => "show_message"})
      end
    end
  end
end

# TODO: Check deprecation in Rails 3
ActionController::Routing::RouteSet::Mapper.send :include, SesMachine::Routing::MapperExtensions
