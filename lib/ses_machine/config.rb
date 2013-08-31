# -*- encoding : utf-8 -*-


module SesMachine #:nodoc:
  class Config #:nodoc:
    include Singleton

    attr_accessor :ses,
                  :dkim_domain, :dkim_selector, :dkim_private_key,
                  :email_server, :email_port, :email_use_ssl, :email_account, :email_password, :email_imap_folders
    attr_reader :database, :use_dkim
    alias_method :use_dkim?, :use_dkim

    # Defaults the configuration options
    def initialize
      reset
    end

    # Reset the configuration options to the defaults.
    #
    # Example:
    #
    # <tt>Config.reset</tt>
    def reset
      @use_dkim = false
      @dkim_domain = nil
      @dkim_selector = nil
      @dkim_private_key = nil
    end

    def load(filename=nil)
      filename = File.join(ENV['RAILS_ROOT'], 'config', 'ses_machine.yml') if filename.blank?
      if File.exist?(filename)
        settings = YAML.load_file(filename)[ENV['RAILS_ENV']]
        from_hash(settings)
      else
        $stderr.puts "WARNING: File '#{filename}' doesn't exist"
      end
    end

    # TODO: fix readme
    # Sets whether the times returned from the database are in UTC or local time.
    # If you omit this setting, then times will be returned in
    # the local time zone.
    #
    # Example:
    #
    # <tt>Config.use_dkim = true</tt>
    #
    # Returns:
    #
    # A boolean
    def use_dkim=(value=false)
      @use_dkim = value
    end

    # Configure SesMachine from a hash that was usually parsed out of yml.
    #
    # Example:
    #
    # <tt>SesMachine::Config.instance.from_hash({})</tt>
    def from_hash(settings)
      _database(settings)
      settings.except('database').each_pair do |name, value|
        send("#{name}=", value) if respond_to?(name)
      end
    end

    # Sets the Mongo::DB database to be used. If the object trying to be
    # set is not a valid +Mongo::DB+, then an error will be raised.
    #
    # Example:
    #
    # <tt>Config.database = Mongo::Connection.db('test')</tt>
    #
    # Returns:
    #
    # The +Mongo::DB+ instance.
    def database=(db)
      check_database!(db)
      @database = db
    end

    protected

    # Check if the database is valid and the correct version.
    #
    # Example:
    #
    # <tt>config.check_database!</tt>
    def check_database!(database)
      raise Errors::InvalidDatabase.new(database) unless database.kind_of?(Mongo::DB)
    end

    # Get a database from settings.
    #
    # Example:
    #
    # <tt>config._database({})</tt>
    def _database(settings)
      name = settings['database']['name']
      host = settings['database']['host'] || 'localhost'
      port = settings['database']['port'] || 27017
      self.database = Mongo::Connection.new(host, port).db(name)
    end
  end
end
