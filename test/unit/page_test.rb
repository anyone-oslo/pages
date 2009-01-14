# allow this test to hook into the Rails framework
require File.dirname(__FILE__) + '/../test_helper'

class PageTest < Test::Unit::TestCase

	fixtures :pages, :textbits
	
	def test_validations
		assert !Page.new.valid?
		page = Page.new( :name => 'Testpage' )
		assert_valid page
		assert page.save
	end
	
	def test_create_with_blank_attributes
		page = Page.new.translate( :eng )
		assert page.update_attributes( :name => 'Testpage', :body => '', :excerpt => '' )
		assert_valid page
	end
	
	def test_slugging
		page = Page.new( :name => 'Værhaner' )
		assert_equal 'vaerhaner', page.slug
		assert_equal 'aerlighet_aeoeaa_aeoeaa', Page.new( :name => "Ærlighet ÆØÅ æøå" ).slug
		assert_equal '1-home', pages( :front ).translate( :eng ).to_param
		assert_equal '1-hjem', pages( :front ).translate( :nor ).to_param
	end
	
	def test_find_by_slug
		assert !Page.find_by_slug_and_language( 'home', :nor )
		# Search by legacy slug
		assert_equal pages( :news ), Page.find_by_slug_and_language( 'latest-news', :eng )
		# Search by name
		assert_equal pages( :front ), Page.find_by_slug_and_language( 'home', :eng )
		assert_equal pages( :front ).translate( :nor ), Page.find_by_slug_and_language( 'hjem', :nor )
	end

end