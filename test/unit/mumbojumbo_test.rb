# encoding: utf-8

# allow this test to hook into the Rails framework
require File.dirname(__FILE__) + '/../test_helper'

module TestTranslators
  class OK
    def self.has_key?( key, language, string )
      ( key == :test ) ? true : false
    end
    def self.get_target( key, language, string )
      "OK"
    end
  end
  class Drunk
    def self.has_key?( key, language, string )
      return true
      ( language == :drunk ) ? true : false
    end
    def self.get_target( key, language, string )
      self.drunkify string
    end
    def self.drunkify( string )
      string.gsub( /[s]+/, 'sh' ).gsub( /[k]/, 'hk' )
    end
  end
end

class MumboJumboTest < Test::Unit::TestCase

  def setup
    MumboJumbo.reset_language_paths!
    MumboJumbo.current_language = MumboJumbo.default_language
    MumboJumbo.translators = []
  end

  def test_string_extension
    assert_equal "Hello, world!"[:hello_world], "Hello, world!"
  end

  def test_language_switching
    MumboJumbo.current_language = :test
    assert_equal MumboJumbo.current_language, :test
    MumboJumbo.use_language( :french ) do
      assert_equal MumboJumbo.current_language, :french
    end
    assert_equal MumboJumbo.current_language, :test
  end

  def test_translators
    MumboJumbo.translators << TestTranslators::OK
    MumboJumbo.translators << TestTranslators::Drunk
    assert_equal "Hello, world!"[:hello_world], "Hello, world!"
    MumboJumbo.use_language( :drunk ) do
      assert_equal "Testing"[:test], "OK"
      assert_equal "I has invisible bike"[:invisible_bike], TestTranslators::Drunk.drunkify( "I has invisible bike" )
    end
  end

  def test_without_translators
    MumboJumbo.translators << TestTranslators::OK
    assert_equal "Testing"[:test], "OK"
    MumboJumbo.without_translators do
      assert_equal "Testing"[:test], "Testing"
    end
    assert_equal "Testing"[:test], "OK"
  end

  def test_language_paths
    assert_equal MumboJumbo.language_paths.length, 1
    MumboJumbo.add_language_path( File.dirname(__FILE__) + '/../..' )
    MumboJumbo.add_language_path( File.dirname(__FILE__) + '/../fixtures' )
    assert_equal MumboJumbo.language_paths.length, 3
    assert_equal MumboJumbo.language_paths.last, Rails.root, "Rails.root should be last"
    MumboJumbo.reset_language_paths!
    assert_equal MumboJumbo.language_paths.length, 1
  end

  def test_language_loading
    MumboJumbo.add_language_path( File.dirname(__FILE__) + '/../fixtures' )
    MumboJumbo.load_languages!
    MumboJumbo.use_language( :testlanguage ) do
      assert_equal "Hello, world!"[:hello_world], "Hi there!"
    end
  end

end
