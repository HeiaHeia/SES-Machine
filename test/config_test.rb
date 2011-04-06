require 'test_helper'

class ConfigTest < Test::Unit::TestCase

  def setup
    @config = SesMachine::Config.instance
  end

  def teardown
    @config.send(:remove_instance_variable, :@database) if @config.instance_variable_defined?(:@database)
  end

  def test_load_config
    assert_nil @config.database
    filename = File.join(File.dirname(__FILE__), 'fixtures', 'config', 'ses_machine.yml')
    @config.load(filename)
    assert_not_nil @config.database
  end

  def test_set_database_with_invalid_database
    assert_raise(SesMachine::Errors::InvalidDatabase) { @config.database = 'test' }
  end

  def test_load_config_from_hash
    filename = File.join(File.dirname(__FILE__), 'fixtures', 'config', 'ses_machine.yml')
    settings = YAML.load_file(filename)['test']
    assert_nil @config.database
    @config.from_hash(settings)
    assert_equal 'ses_machine_config_test', @config.database.name
  end
end
