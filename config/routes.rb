# encoding: utf-8

Rails.application.routes.draw do
  image_resources :images, path: "dynamic_images/:digest(/:size)"

  # Pages
  scope path: PagesCore.config.pages_path_scope do
    resources :pages, path: ":locale/pages" do
      collection do
        get "search"
        post "search"
      end
      member do
        post "add_comment"
        put "preview"
      end
      resources :files, controller: "page_files"
    end

    get(
      "/:locale/pages/:id/:page" => "pages#show",
      constraints: { page: /\d+/ }, as: :paginated_page
    )

    # Redirect hack for backwards compatibility
    get "pages/:locale" => redirect("/%{locale}/pages"), locale: /\w\w\w/
    get "pages/:locale/*glob" => redirect("/%{locale}/pages/%{glob}"),
        locale: /\w\w\w/

    get "(/:locale)" => "pages#index" if PagesCore.config.pages_path_scope?
  end

  # Authentication
  resource :session, only: [:create, :destroy]

  # Sitemap
  resource :sitemap, only: [:show]

  namespace :admin do
    # Invites
    resources :invites do
      member do
        post :accept
      end
    end
    controller :invites do
      get "/invites/:id/:token" => :show, as: :invite_with_token
    end

    # Password resets
    resources :password_resets, only: [:create, :show, :update]
    controller :password_resets do
      get "/password_resets/:id/:token" => :show, as: :password_reset_with_token
    end

    # Images
    resources :images

    # Users
    resources :users do
      collection do
        get "deactivated"
        get "login"
      end
      member do
        delete "delete_image"
      end
    end

    # Categories
    resources :categories

    # Pages
    scope ":locale" do
      resources :pages do
        collection do
          get "news"
          get "new_news" # TODO: Should be refactored
          get "reorder_pages"
        end

        member do
          delete "delete_meta_image"
        end

        get "new/:parent", action: "new"

        # Page Images
        resources :images, controller: "page_images" do
          collection do
            put "reorder"
          end
        end

        # Page Files
        resources :files, controller: "page_files" do
          collection do
            post "reorder"
          end
        end

        # Page Files
        resources :comments, controller: "page_comments" do
        end
      end
    end
  end

  # Default admin route
  get(
    "/admin" => redirect do |_env, _req|
      "/admin/#{I18n.default_locale}/pages/news"
    end,
    as: "admin_default"
  )
  # get '/admin' => 'admin#redirect', as: 'admin_default'

  # Errors
  resources :errors do
    collection do
      post "report"
    end
  end

  # Page path routing
  get(
    ":locale/*path" => "pages#show",
    constraints: PagesCore::PagePathConstraint.new
  )
  get(
    "*path" => "pages#show",
    constraints: PagesCore::PagePathConstraint.new,
    defaults: { locale: I18n.default_locale.to_s }
  )

  # Legacy routes
  get "/comments/:action/:type/:id", controller: "comments"
end
