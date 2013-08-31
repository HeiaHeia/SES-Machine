# -*- encoding : utf-8 -*-


module SesMachine #:nodoc
  module Errors #:nodoc

    # Raised when the database connection has not been set up properly, either
    # by attempting to set an object on the db that is not a +Mongo::DB+, or
    # not setting anything at all.
    #
    # Example:
    #
    # <tt>InvalidDatabase.new("Not a DB")</tt>
    class InvalidDatabase < StandardError
      def initialize(database)
        @database = database
      end

      def message
        "Database should be a Mongo::DB, not #{@database.class.name}"
      end
    end
  end
end
