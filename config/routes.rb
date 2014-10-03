# encoding: utf-8

Rails.application.routes.draw do

  image_resources :images, path: "dynamic_images/:digest(/:size)"

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
  get '/:locale/pages/:id/:page' => 'pages#show', :constraints => { :page => /\d+/ }, :as => :paginated_page

  # Redirect hack for backwards compatibility
  get 'pages/:locale' => redirect("/%{locale}/pages"), :locale => /\w\w\w/
  get 'pages/:locale/*glob' => redirect("/%{locale}/pages/%{glob}"), :locale => /\w\w\w/

  # Authentication
  resource :session,        only: [:create, :destroy]
  resource :password_reset, only: [:create]

  namespace :admin do

    # Images
    resources :images

    # Users
    resources :users do
      collection do
        get 'deactivated'
        get  'welcome'
        post 'create_first'
        get  'login'
        get 'deactivated'
      end
      member do
        delete 'delete_image'
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
          get  'import_xml'
          post 'import_xml'
        end

        get 'new/:parent', :action => 'new'

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

        # Page Files
        resources :comments, :controller => 'page_comments' do
        end
      end
    end

  end

  # Default admin route
  get '/admin' => redirect{ |env, req| "/admin/#{I18n.default_locale.to_s}/pages/news" }, :as => 'admin_default'
  #get '/admin' => 'admin#redirect', :as => 'admin_default'

  # Errors
  resources :errors do
    collection do
      post 'report'
    end
  end

  # Legacy routes
  get '/comments/:action/:type/:id', :controller => 'comments'

end
