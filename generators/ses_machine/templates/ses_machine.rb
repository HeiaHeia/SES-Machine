ActionMailer::Base.custom_amazon_ses_mailer = AWS::SES::Base.new(:secret_access_key => 'secret_access_key', :access_key_id => 'access_key_id')
ActionMailer::Base.delivery_method = :ses_machine

SesMachine.configure do |config|
  # Email configuration for rake tasks
  config.email_server = 'imap.googlemail.com'
  config.email_port = 993
  config.email_use_ssl = true
  config.email_account = 'username@gmail.com'
  config.email_password = '12345'
  config.email_imap_folders = ['INBOX', '[Gmail]/Spam']

  # DKIM
  # config.use_dkim = true
  # config.dkim_domain = 'example.com'
  # config.dkim_selector = 'ses'
  # config.dkim_private_key = '/path/to/private/key'
end


