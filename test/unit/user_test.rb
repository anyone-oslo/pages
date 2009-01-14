# allow this test to hook into the Rails framework
require File.dirname(__FILE__) + '/../test_helper'


class UserTest < Test::Unit::TestCase

	fixtures :users

	# test create/read/update/delete
	def test_crud
		assert_equal 4, User.count
		my_user = User.new( { :username => 'testuser1', :realname => 'Test User', :password => 'testpassword', :email => 'test@test.com' } )
		assert my_user.save
		jimmy = User.find( my_user.id )
		assert_equal jimmy.username, my_user.username
		jimmy.username = "newusername"
		assert jimmy.save
		assert jimmy.destroy
	end
	
	def test_find_by_username_or_email
		#assert User.find_by_username_or_email( 'inge' )
		#assert User.find_by_username_or_email( 'inge@manualdesign.no' )
		#assert_equal users(:inge), User.find_by_id_or_username( 2 )
		#assert_equal users(:inge), User.find_by_id_or_username( 'inge' ) 
	end

	# test creation of users
	def test_password_creation
		my_user = User.create( { :username => 'testuser1', :realname => 'Test User', :password => 'testpassword' } )
		assert_equal my_user.hashed_password, User.hash_string( 'testpassword' )
	end
	
	# test the password hashing function
	def test_password_hasher
		assert_equal users(:inge).hashed_password, User.hash_string( "ingepassord" )
	end
	
	# test relations
	def test_relations
		assert_equal users(:thomas).creator, users(:inge)
		assert users(:inge).created_users.include?( users(:thomas) )
	end
	
	# test uniqueness of usernames
	def test_username_uniqueness
		assert User.create( :username => 'inge', :realname => 'Silly User', :password => 'passs', :email => 'test@test.com' )
	end

	def test_web_link
		users(:inge).web_link = "www.elektronaut.no"
		assert users(:inge).save
		assert_equal 'http://www.elektronaut.no', users(:inge).web_link
	end

end
