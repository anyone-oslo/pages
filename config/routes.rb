# encoding: utf-8

Rails.application.routes.draw do

  # Pages
  resources :pages, :path => ":locale/pages" do
    collection do
      get  'search'
      post 'search'
    end
    member do
      post 'add_comment'
      put 'preview'
    end
    resources :files, :controller => 'page_files'
  end
  match '/:locale/pages/:id/:page' => 'pages#show', :constraints => { :page => /\d+/ }, :as => :paginated_page

  # Redirect hack for backwards compatibility
  get 'pages/:locale' => redirect("/%{locale}/pages"), :locale => /\w\w\w/
  get 'pages/:locale/*glob' => redirect("/%{locale}/pages/%{glob}"), :locale => /\w\w\w/

  # OpenID
  resource :openid, :controller => 'openid' do
    member do
      get 'complete'
    end
  end

  namespace :admin do

    # Images
    resources :images

    # Users
    resources :users do
      collection do
        get 'deactivated'
        get  'new_password'
        post 'reset_password'
        get  'welcome'
        post 'create_first'
        get  'login'
        post 'login'
        get  'logout'
        get 'deactivated'
      end
      member do
        delete 'delete_image'
        get 'update_openid'
      end
    end

    # Categories
    resources :categories

    # Pages
    scope ":locale" do
      resources :pages do
        collection do
          get 'news'
          get 'new_news' # TODO: Should be refactored
          get 'reorder_pages'
        end
        member do
          get  'delete_comment'
          get  'import_xml'
          post 'import_xml'
        end

        match 'new/:parent', :action => 'new'

        # Page Images
        resources :images, :controller => 'page_images' do
          collection do
            put 'reorder'
          end
        end

        # Page Files
        resources :files, :controller => 'page_files' do
          collection do
            post 'reorder'
          end
        end
      end
    end

  end

  # Default admin route
  match '/admin' => redirect{ |env, req| "/admin/#{Language.default}/pages/news" }, :as => 'admin_default'
  #match '/admin' => 'admin#redirect', :as => 'admin_default'

  # Errors
  resources :errors do
    collection do
      post 'report'
    end
  end

  # Legacy routes
  match '/comments/:action/:type/:id', :controller => 'comments'

end
