# encoding: utf-8

require File.dirname(__FILE__) + '/../test_helper'

# Re-raise errors caught by the controller.
class ActionController::Base; def rescue_action(e); raise e; end; end

class PagesControllerTest < Test::Unit::TestCase

  fixtures :pages, :textbits

  NONEXISTANT_PAGE_ID = 999

  def setup
    @controller = PagesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @controller.class.layout false # disable layout for this test
  end

  ## ---- ASSERTS ----

  def assert_shows_language( language )
    get :show, :id => 1, :language => language
    assert_response :success
    assert_not_nil  assigns['language']
    assert_equal    language,      assigns['language']
    assert_equal    language,      assigns['page'].working_language
    assigns['root_pages'].each do |root_page|
      assert_equal language, root_page.working_language
    end
  end

  ## ---- TESTS ----

  def test_index
    get :index
    assert_response :success
    assert_not_nil  assigns['page']
    assert_equal    pages(:front),   assigns['page']
  end

  def test_show
    get :show, :id => 1, :language => 'eng'
    assert_response :success
    assert_not_nil  assigns['page']
    assert_equal    pages(:front),   assigns['page']
  end

  def test_root_pages
    get :show, :id => 1, :language => 'eng'
    assert_response :success
    assert_not_nil  assigns['root_pages']
    assert_equal    2, assigns['root_pages'].length
    get :show, :id => 1, :language => 'nor'
    assert_response :success
    assert_not_nil  assigns['root_pages']
    assert_equal    1, assigns['root_pages'].length
  end

  def test_language
    assert_shows_language( 'eng' )
    assert_shows_language( 'nor' )
  end

  def test_nonexistant_page
    get :show, :id => NONEXISTANT_PAGE_ID
    assert_response 404
    assert_template "errors/404", "Should render the 404 template"
  end

  def test_no_pages_created
    Page.destroy_all
    get :index
    assert_response 404, "Should return 404 if no pages exist"
  end

  def test_routing
    assert_routing 'pages/eng/1-home', { :controller => 'pages', :action => 'show', :id => pages(:front).translate( :eng ).to_param, :language => 'eng' }
    assert_routing 'pages/nor/1-hjem', { :controller => 'pages', :action => 'show', :id => pages(:front).translate( :nor ).to_param, :language => 'nor' }

    assert_recognizes(
      { :controller => 'pages', :action => 'index' },
      "/"
    )
    assert_recognizes(
      { :controller => 'pages', :action => 'index' },
      "/pages"
    )
    assert_recognizes(
      { :controller => 'pages', :action => 'index', :language => 'eng' },
      "/pages/eng"
    )
    assert_recognizes(
      { :language => 'eng', :controller => 'pages', :action => 'show', :id => '1' },
      "/pages/eng/1"
    )
    assert_recognizes(
      { :language => 'eng', :controller => 'pages', :action => 'show', :id => '1-front_page' },
      "/pages/eng/1-front_page"
    )
    assert_recognizes(
      { :controller => 'pages', :action => 'show', :id => '1' },
      "/pages/1"
    )
    assert_recognizes(
      { :controller => 'pages', :action => 'show', :id => '1-front_page' },
      "/pages/1-front_page"
    )
  end

end
