#require 'test_helper'
#
#class InternalHelpersTest < ActiveSupport::TestCase
#
#  def test_get_keywords
#    words = ['Q', 'qw', 'QWE', 'Й', 'йц', 'ЙЦУ', '1', '12', '123']
#    assert_equal ['qwe', 'йцу', '123'], SesMachine::InternalHelpers.get_keywords(words)
#  end
#end
