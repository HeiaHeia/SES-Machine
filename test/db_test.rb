require 'test_helper'

class DBTest < ActiveSupport::TestCase

  def setup
    SesMachine.config.load(File.join(File.dirname(__FILE__), 'fixtures', 'config', 'ses_machine.yml'))
    SesMachine.database['mails'].remove
    SesMachine.database['daily_stats'].remove
  end

  def teardown
    SesMachine.database['mails'].remove
    SesMachine.database['daily_stats'].remove
  end

#  def test_get_keywords
#    words = ['Q', 'qw', 'QWE', 'Й', 'йц', 'ЙЦУ', '1', '12', '123']
#    assert_equal ['qwe', 'йцу', '123'], SesMachine::DB.get_keywords(words)
#  end

  def test_update_daily_stats
    SesMachine.database['mails'].insert('bounce_type' => SesMachine::Bounce::TYPES[:mail_sent], 'date' => 2.day.ago.to_time.utc)
    SesMachine.database['mails'].insert('bounce_type' => SesMachine::Bounce::TYPES[:unknown], 'date' => Time.now.utc)
    SesMachine.database['mails'].insert('bounce_type' => SesMachine::Bounce::TYPES[:hard_bounce], 'date' => Time.now.utc)

    response = SesMachine::DB.update_daily_stats

    assert_equal 3, SesMachine.database['mails'].count
    assert_equal 2, SesMachine.database['daily_stats'].count
    assert_equal 1, response['ok']
  end
end
