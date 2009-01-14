# allow this test to hook into the Rails framework
require File.dirname(__FILE__) + '/../test_helper'

class MockVideoHelper
	include VideoHelper
end


class VideoEmbedHelperTest < Test::Unit::TestCase
	
	def setup
		@helper = MockVideoHelper.new

		@youtube_id    = "oHg5SJYRHA0"
		@youtube_link  = "http://www.youtube.com/watch?v=oHg5SJYRHA0"
		@youtube_embed = "<object width=\"425\" height=\"344\"><param name=\"movie\" value=\"http://www.youtube.com/v/oHg5SJYRHA0&rel=1\"></param><param name=\"wmode\" value=\"transparent\"></param><embed src=\"http://www.youtube.com/v/oHg5SJYRHA0&rel=1\" type=\"application/x-shockwave-flash\" wmode=\"transparent\" width=\"425\" height=\"344\"></embed></object>"
		@youtube_embed_resized = "<object width=\"325\" height=\"263\"><param name=\"movie\" value=\"http://www.youtube.com/v/oHg5SJYRHA0&rel=1\"></param><param name=\"wmode\" value=\"transparent\"></param><embed src=\"http://www.youtube.com/v/oHg5SJYRHA0&rel=1\" type=\"application/x-shockwave-flash\" wmode=\"transparent\" width=\"325\" height=\"263\"></embed></object>"

		@imeem_id      = "3q8wA4egjr"
		@imeem_embed   = "<object width=\"460\" height=\"390\"><param name=\"movie\" value=\"http://media.imeem.com/v/3q8wA4egjr/aus=false/pv=2\"></param><param name=\"allowFullScreen\" value=\"true\"></param><embed src=\"http://media.imeem.com/v/3q8wA4egjr/aus=false/pv=2\" type=\"application/x-shockwave-flash\" width=\"460\" height=\"390\" allowFullScreen=\"true\"></embed></object>"
		@imeem_embed_resized = "<object width=\"300\" height=\"254\"><param name=\"movie\" value=\"http://media.imeem.com/v/3q8wA4egjr/aus=false/pv=2\"></param><param name=\"allowFullScreen\" value=\"true\"></param><embed src=\"http://media.imeem.com/v/3q8wA4egjr/aus=false/pv=2\" type=\"application/x-shockwave-flash\" width=\"300\" height=\"254\" allowFullScreen=\"true\"></embed></object>"
	end

	def test_id_converting
		assert_equal @youtube_id, @helper.youtube_id( @youtube_id )
		assert_equal @youtube_id, @helper.youtube_id( @youtube_link )
		assert_equal @youtube_id, @helper.youtube_id( @youtube_embed )
		assert_equal @imeem_id, @helper.imeem_id( @imeem_id )
		assert_equal @imeem_id, @helper.imeem_id( @imeem_embed )
	end
	
	def test_embedding
		assert_equal @youtube_embed, @helper.youtube_embed( @youtube_id )
		assert_equal @youtube_embed, @helper.youtube_embed( @youtube_link )
		assert_equal @youtube_embed, @helper.youtube_embed( @youtube_embed )
		assert_equal @imeem_embed, @helper.imeem_embed( @imeem_id )
		assert_equal @imeem_embed, @helper.imeem_embed( @imeem_embed )
	end
	
	def test_resizing
		assert_equal @youtube_embed_resized, @helper.youtube_embed( @youtube_id, :width => 325, :height => 263 )
		assert_equal @youtube_embed_resized, @helper.youtube_embed( @youtube_id, :width => 325 )
		assert_equal @imeem_embed_resized, @helper.imeem_embed( @imeem_id, :width => 300, :height => 254 )
		assert_equal @imeem_embed_resized, @helper.imeem_embed( @imeem_id, :width => 300 )
	end
	
	def test_transparency
		assert_equal @youtube_embed, @helper.video_embed( @youtube_link )
		assert_equal @imeem_embed,   @helper.video_embed( @imeem_embed )
	end

end
