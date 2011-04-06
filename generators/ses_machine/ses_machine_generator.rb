class SesMachineGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.directory 'config'
      m.template 'ses_machine.yml', 'config/ses_machine.yml'

      m.directory 'config/initializers'
      m.template 'ses_machine.rb', 'config/initializers/ses_machine.rb'
      m.template 'ses_machine_hooks.rb', 'config/initializers/ses_machine_hooks.rb'

      m.directory 'public/stylesheets'
      m.template 'ses_machine.css', 'public/stylesheets/ses_machine.css'

      m.readme 'README' unless ENV['RAILS_ENV'].eql?('test')
    end
  end
end
