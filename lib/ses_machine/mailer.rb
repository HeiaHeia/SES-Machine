# encoding: utf-8

module SesMachine #:nodoc:
  module Mailer #:nodoc:

    def perform_delivery_ses_machine(mail)
      puts '-----SES-----' # TODO: remove
      mail = Mail.read_from_string(mail.encoded) if ActionMailer::VERSION::MAJOR < 3
      raw_source = SesMachine.use_dkim? ? sign_mail(mail) : mail.encoded
      # TODO: rescue ResponseError
      response = ActionMailer::Base.custom_amazon_ses_mailer.send_raw_email(raw_source, :source => 'bounces@heiaheia.com') # TODO: Move to config
  
      doc = {
        :address => mail.to,
        :subject => mail.subject,
        :raw_source => raw_source,
        :date => response.headers['date'].to_time.utc,
        :message_id => response.message_id,
        :request_id => response.request_id,
        :response => response.to_s,
        :response_code => response.code,
        :response_error => response.error.to_s,
        :bounce_type => 0,
        '_keywords' => SesMachine::InternalHelpers.get_keywords(mail.to + mail.subject.split)
      }

      SesMachine.database['mails'].insert(doc)
    end

    protected

    def dkim_signer
      key = File.readlines(SesMachine.dkim_private_key).join
      DKIM::Signer.new(SesMachine.dkim_domain, SesMachine.dkim_selector, key)
    end

    def sign_mail(mail)
      # Read more: http://docs.amazonwebservices.com/ses/latest/DeveloperGuide/DKIM.html
      exclude_headers = ['Message-Id', 'Date', 'Return-Path', 'Bounces-To']
      exclude_headers_rxp = /^(#{exclude_headers.join('|')}):/i
      signer = dkim_signer
      raw_source = ''
      mail.encoded.each_line do |line|
        unless line =~ exclude_headers_rxp
          unless line.blank?
            line.gsub!(/\n/, "\r\n")
            line.gsub!(/\r+/, "\r")
          end
          signer.feed(line)
          raw_source << line
        end
      end
      signature = signer.finish
      "#{signature.signature_header}\r\n#{raw_source}"
    end

  end
end

ActionMailer::Base.send :include, SesMachine::Mailer