namespace :ses_machine do
  desc 'Check email with IMAP for new bounced and spam messages'
  task :check_email_imap => :environment do

    imap = Net::IMAP.new(SesMachine.email_server, SesMachine.email_port, SesMachine.email_use_ssl)
    imap.login(SesMachine.email_account, SesMachine.email_password)
    t = SesMachine.database['mails']

    SesMachine.email_imap_folders.each do |folder|
      imap.select(folder)
      imap.search(['FROM', 'email-bounces.amazonses.com', 'NOT', 'SEEN']).each do |message_id|
        data = imap.fetch(message_id, ['UID', 'ENVELOPE', 'RFC822'])[0]
        # imap.store(message_id, "-FLAGS", [:Seen]) # Keep message as unread
        mail = Mail.read_from_string(data.attr['RFC822'])
        bounce = {
          :uid => data.attr['UID'],
          :message_id => data.attr['ENVELOPE']['message_id'].split('@').first[1..-1],
          :raw_source => data.attr['RFC822'],
          :date => data.attr['ENVELOPE']['date'].to_time.utc
        }
        message_id = data.attr['ENVELOPE']['in_reply_to'].split('@').first[1..-1]
        email = t.find_one('_id' => BSON::ObjectId(message_id))['address'].first
        if mail.bounced?
          if mail.retryable?
            bounce_type = SesMachine::Bounce::TYPES[:soft_bounce]
            SesMachine::Hooks.soft_bounce_hook(email) if SesMachine::Hooks.respond_to?(:soft_bounce_hook)
          else
            bounce_type = SesMachine::Bounce::TYPES[:hard_bounce]
            SesMachine::Hooks.hard_bounce_hook(email) if SesMachine::Hooks.respond_to?(:hard_bounce_hook)
          end
          bounce.merge!(:details => mail.diagnostic_code.to_s)
        # TODO: Add check for spam
        else
          bounce_type = SesMachine::Bounce::TYPES[:unknown]
          SesMachine::Hooks.unknown_hook(email) if SesMachine::Hooks.respond_to?(:unknown_hook)
        end
        
        t.update({'message_id' => message_id}, {'$set' => {'bounce' => bounce, 'bounce_type' => bounce_type}})
      end
    end
    imap.logout()
    imap.disconnect()
  end
end
