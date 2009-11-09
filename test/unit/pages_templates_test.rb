# allow this test to hook into the Rails framework
require File.dirname(__FILE__) + '/../test_helper'

class PagesTemplatesTest < Test::Unit::TestCase
	
	context "The PagesCore::Templates module" do

		should "should be configurable" do
			assert_nothing_raised do
				PagesCore::Templates.configure
				PagesCore::Templates.configure(:reset => true)
				PagesCore::Templates.configure(:reset => :defaults)
			end
		end
		
		context "with defaults loaded" do
			setup { PagesCore::Templates.configure(:reset => :defaults) }
			
			should "return it's configuration" do
				assert PagesCore::Templates.configuration
				assert_kind_of PagesCore::Templates::Configuration, PagesCore::Templates.configuration
			end
		end
		
	end
	
end
