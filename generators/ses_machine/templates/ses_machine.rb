SesMachine.configure do |config|
  # Email configuration for rake tasks
  config.email_server = 'imap.googlemail.com'
  config.email_port = 993
  config.email_use_ssl = true
  config.email_account = 'username@gmail.com' # The email address to which bounce notifications are to be forwarded.
  config.email_password = '12345'
  config.email_imap_folders = ['INBOX', '[Gmail]/Spam']

  # DKIM
  config.use_dkim = false
  # config.dkim_domain = 'example.com'
  # config.dkim_selector = 'ses'
  # config.dkim_private_key = '/path/to/private/key'
end


