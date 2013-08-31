# -*- encoding : utf-8 -*-

require 'test_helper'

class DBTest < ActiveSupport::TestCase

  def setup
    SesMachine.config.load(File.join(File.dirname(__FILE__), 'fixtures', 'config', 'ses_machine.yml'))
    SesMachine.database['mails'].remove
    SesMachine.database['daily_stats'].remove
    SesMachine.database['monthly_stats'].remove
  end

  def teardown
    SesMachine.database['mails'].remove
    SesMachine.database['daily_stats'].remove
    SesMachine.database['monthly_stats'].remove
  end

#  def test_get_keywords
#    words = ['Q', 'qw', 'QWE', 'Й', 'йц', 'ЙЦУ', '1', '12', '123']
#    assert_equal ['qwe', 'йцу', '123'], SesMachine::DB.get_keywords(words)
#  end

  def test_update_daily_stats
    load_mails
    response = SesMachine::DB.update_daily_stats
    assert_equal 3, SesMachine.database['mails'].count
    assert_equal 2, SesMachine.database['daily_stats'].count
    assert_equal 1, response['ok']
  end

  def test_update_monthly_stats
    load_mails
    SesMachine::DB.update_daily_stats
    assert_equal 0, SesMachine.database['monthly_stats'].count
    response = SesMachine::DB.update_monthly_stats
    assert_equal 2, SesMachine.database['monthly_stats'].count
    assert_equal 1, response['ok']
  end

  private

  def load_mails
    SesMachine.database['mails'].insert('bounce_type' => SesMachine::Bounce::TYPES[:mail_sent], 'date' => 2.month.ago.to_time.utc)
    SesMachine.database['mails'].insert('bounce_type' => SesMachine::Bounce::TYPES[:unknown], 'date' => Time.now.utc)
    SesMachine.database['mails'].insert('bounce_type' => SesMachine::Bounce::TYPES[:hard_bounce], 'date' => Time.now.utc)
  end

end
