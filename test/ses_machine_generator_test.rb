# -*- encoding : utf-8 -*-

require 'test_helper'
require 'rails_generator'
require 'rails_generator/scripts/generate'

generators_path = File.join(File.dirname(__FILE__), '..', 'generators')
Rails::Generator::Base.append_sources(Rails::Generator::PathSource.new(:plugin, generators_path))

class SesMachineGeneratorTest < Test::Unit::TestCase

  def setup
    FileUtils.mkdir_p(fake_rails_root)
  end

  def teardown
    FileUtils.rm_r(fake_rails_root)
  end

  def test_generates_correct_files
    Rails::Generator::Scripts::Generate.new.run(['ses_machine'], :destination => fake_rails_root, :quiet => true)
    assert File.exist?(File.join(fake_rails_root, 'config', 'ses_machine.yml'))
    assert File.exist?(File.join(fake_rails_root, 'config', 'initializers', 'ses_machine.rb'))
    assert File.exist?(File.join(fake_rails_root, 'config', 'initializers', 'ses_machine_hooks.rb'))
    assert File.exist?(File.join(fake_rails_root, 'public', 'stylesheets', 'ses_machine.css'))
  end

  private

  def fake_rails_root
    File.join(File.dirname(__FILE__), 'rails_root')
  end

  def file_list
    Dir.glob(File.join(fake_rails_root, '*'))
  end

end
