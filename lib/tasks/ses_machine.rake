require 'net/imap'

namespace :ses_machine do
  desc 'Check email with IMAP for new bounced and spam messages'
  task :check_email_imap => :environment do

    imap = Net::IMAP.new(SesMachine.email_server, SesMachine.email_port, SesMachine.email_use_ssl)
    imap.login(SesMachine.email_account, SesMachine.email_password)
    t = SesMachine.database['mails']

    folders = SesMachine::Bounce::TYPES.keys.map {|i| i.to_s.classify}
    folders.delete('EmailSent')
    folders << 'MessageNotFound'
    folders.each do |folder|
      imap.create("SesMachine/#{folder}") unless imap.list('SesMachine/', folder)
    end

    SesMachine.email_imap_folders.each do |folder|
      imap.select(folder)
      imap.search(['FROM', 'email-bounces.amazonses.com', 'NOT', 'SEEN']).each do |message|
        data = imap.fetch(message, ['UID', 'ENVELOPE', 'RFC822'])[0]
        mail = Mail.read_from_string(data.attr['RFC822'])
        message_id = data.attr['ENVELOPE']['in_reply_to']
        if message_id.blank?
          message_id = mail['X-Original-To'].to_s.split('@').first
        else
          message_id = message_id.split('@').first[1..-1]
        end
        doc = t.find_one('message_id' => message_id)
        if doc
          email = doc['address'].first
          bounce = {
            :uid => data.attr['UID'],
            :message_id => data.attr['ENVELOPE']['message_id'].split('@').first[1..-1],
            :raw_source => data.attr['RFC822'],
            :date => data.attr['ENVELOPE']['date'].to_time.utc
          }
          if mail['auto-submitted'].to_s == 'auto-replied'
              imap.copy(message, 'SesMachine/AutoResponder')
              bounce_type = SesMachine::Bounce::TYPES[:auto_responder]
              SesMachine::Hooks.auto_responder_hook(email) if SesMachine::Hooks.respond_to?(:auto_responder_hook)
          elsif mail.bounced?
            if mail.retryable?
              imap.copy(message, 'SesMachine/SoftBounce')
              bounce_type = SesMachine::Bounce::TYPES[:soft_bounce]
              SesMachine::Hooks.soft_bounce_hook(email) if SesMachine::Hooks.respond_to?(:soft_bounce_hook)
            else
              imap.copy(message, 'SesMachine/HardBounce')
              bounce_type = SesMachine::Bounce::TYPES[:hard_bounce]
              SesMachine::Hooks.hard_bounce_hook(email) if SesMachine::Hooks.respond_to?(:hard_bounce_hook)
            end
            bounce.merge!(:details => mail.diagnostic_code.to_s)
          else
            imap.copy(message, 'SesMachine/Unknown')
            bounce_type = SesMachine::Bounce::TYPES[:unknown]
            SesMachine::Hooks.unknown_hook(email) if SesMachine::Hooks.respond_to?(:unknown_hook)
          end
          t.update({'_id' => doc['_id']}, {'$set' => {'bounce' => bounce, 'bounce_type' => bounce_type}})
        else
          imap.copy(message, 'SesMachine/MessageNotFound')
        end
      end
    end
    SesMachine.email_imap_folders.each do |folder|
      imap.select(folder)
      imap.search(['FROM', 'complaints@email-abuse.amazonses.com', 'NOT', 'SEEN']).each do |message|
        data = imap.fetch(message, ['UID', 'ENVELOPE', 'RFC822'])[0]
        message_id = data.attr['RFC822'].grep(/^Message-ID: (.+)\n/ix)[1][/<(.+)@/, 1]
        doc = t.find_one('message_id' => message_id)
        if doc
          email = doc['address'].first
          bounce = {
            :uid => data.attr['UID'],
            :message_id => data.attr['ENVELOPE']['message_id'].split('@').first[1..-1],
            :raw_source => data.attr['RFC822'],
            :date => data.attr['ENVELOPE']['date'].to_time.utc
          }
          imap.copy(message, 'SesMachine/SpamComplaint')
          SesMachine::Hooks.spam_complaint_hook(email) if SesMachine::Hooks.respond_to?(:spam_complaint_hook)
          t.update({'_id' => doc['_id']}, {'$set' => {'bounce' => bounce, 'bounce_type' => SesMachine::Bounce::TYPES[:spam_complaint]}})
        else
          imap.copy(message, 'SesMachine/MessageNotFound')
        end
      end
    end
    imap.logout()
    imap.disconnect()
  end
end
