# allow this test to hook into the Rails framework
require File.dirname(__FILE__) + '/../test_helper'

class TextableTest < Test::Unit::TestCase

	fixtures :pages, :textbits
	
	#def setup
	#end
	
	def test_languages
		assert_equal 3, Page.languages.length,                      "Page should have 3 languages"
	end
	
	def test_textile
		page = pages(:news_item)
		page.working_language = 'eng'
		assert_equal "This is the first post.\nIt has several lines.", page.body.to_s
		assert_equal "<p>This is the first post.<br />\nIt has several lines.</p>", page.body.to_html
	end
	
	def test_block_translate
		page = pages( :front )
		page.working_language = 'eng'
		page.translate( :eng ) do |translated|
			assert_equal 'eng',  translated.working_language,       "Working language should be english"
			assert_equal 'Home', translated.name.to_s,              "Page title should be 'Home'"
		end
		page.translate( :nor ) do |translated|
			assert_equal 'nor',  translated.working_language,       "Working language should be norwegian"
			assert_equal 'Hjem', translated.name.to_s,              "Page title should be 'Home'"
		end
		assert_equal 'eng', page.working_language,                  "Original page should still have english as working language"
	end

	def test_translation
		page = pages( :front )
		page.working_language = 'nor'
		assert_equal 2, page.languages.length,                      "Page should only have two languages"
		assert_equal 'Hjem', page.name.to_s,                        "Page name should equal 'Hjem'"
		assert_equal '',     page.excerpt.to_s,                     "Missing textbit for existing language should return blank"
		assert_equal '',     page.sidebar.to_s,                     "Missing textbit for existing language should return blank"
		page.working_language = 'ger'
		assert_equal '',     page.excerpt.to_s,                     "Missing predefined textbit for missing language should return blank"
	end
	
	def test_textbit_creation
		page = pages( :front )
		textbit_count = Textbit.count
		assert       page.translate( :nor ).sidebar.new_record?,    "page.sidebar should be a new record"
		assert_equal textbit_count, Textbit.count,                  "No new textbits should have been added"
		assert page.save,                                           "Should be able to save page"
		assert_equal textbit_count, Textbit.count,                  "No new textbits should have been added"
	end

	def test_adding_field
		assert !pages( :front ).has_field?( :extended )
		assert_raises( NoMethodError ){ pages(:front).extended = "Extended" }
		assert_nothing_raised do
			page = pages( :front )
			page.add_field :extended 
			page.extended = "Extended"
			assert_valid page
			assert page.save,                                      "Should be able to save page"
		end
	end
	
	def test_blank_fields
		textbit_count = Textbit.count
		page = pages( :front )
		assert !page.excerpt?
		page.excerpt = "Testing"
		assert page.save
		assert_equal (textbit_count+1), Textbit.count
		page.excerpt = ""
		assert page.save
		assert_equal textbit_count, Textbit.count
	end
	
	def test_blank_strings
		page = Page.create( :name => 'Testpage' )
		assert_equal '', page.body.to_html
	end
	
	def test_has_field
		assert pages(:front).translate(:eng).body?
		assert_raises( NoMethodError ) { pages(:front).no_such_field? }
		pages( :front ).translate( :nor ) do |page|
			assert page.body?
			assert !page.excerpt?
			assert !page.sidebar?
			page.excerpt = "Testing"
			assert page.excerpt?
			page.sidebar = "Testing"
			assert page.sidebar?
			assert_valid page
		end
	end
	
	def test_set_from_hash
		params = {
			:name => { :nor => "Dette er en test", :eng => "This is a test" },
			:body => { :nor => "Norsk test", :eng => "English test" }
		}
		page = Page.create( params )
		assert_valid page
		assert_equal "Dette er en test", page.translate( 'nor' ).name.to_s
		assert_equal "This is a test",   page.translate( 'eng' ).name.to_s
	end
	
end