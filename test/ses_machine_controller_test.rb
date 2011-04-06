require 'test_helper'

class SesMachineControllerTest < ActionController::TestCase
  def setup
    SesMachine.config.load(File.join(File.dirname(__FILE__), 'fixtures', 'config', 'ses_machine.yml'))
    SesMachine.database['mails'].insert('_id' => BSON::ObjectId('4d95f4ebf023ca49fa000001'),
                                        'date' => Time.now.utc,
                                        'address' => ['test@example.com'],
                                        'subject' => 'Test mail',
                                        'raw_source' => 'Test')
    ActionController::Routing::Routes.draw { |map| map.ses_machine }
  end

  def teardown
    SesMachine.database['mails'].remove
  end

  def test_index
    get :index
    assert_response :success
    assert_not_nil assigns(:count_mails_sent)
    assert_not_nil assigns(:count_mails_bounced)
    assert_not_nil assigns(:count_spam_complaints)
  end

  def test_activity
    get :activity
    assert_response :success
    assert_not_nil assigns(:messages)
    assert_not_nil assigns(:page)
  end

  def test_show_message
    get :show_message, :id => '4d95f4ebf023ca49fa000001'
    assert_response :success
    assert_not_nil assigns(:mail)
  end

  def test_show_message_without_id
    get :show_message, :id => '12345'
    assert_redirected_to ses_machine_path
    assert_not_nil flash[:error]
  end
end
