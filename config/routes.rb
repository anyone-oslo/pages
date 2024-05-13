# frozen_string_literal: true

Rails.application.routes.draw do
  Healthcheck.routes(self)

  image_resources :images, path: "dynamic_images/:digest(/:size)"

  # Attachment
  resources :attachments, path: "attachments/:digest", only: %i[show] do
    member do
      get :download
    end
  end

  # Pages
  resources :pages, path: ":locale/pages" do
    collection do
      get "search"
      post "search"
      post "preview"
    end
    resources :files, controller: "page_files"
  end

  get "/:locale/pages/:id/:page" => "pages#show",
      constraints: { page: /\d+/ }, as: :paginated_page

  # Redirect hack for backwards compatibility
  get "pages/:locale" => redirect("/%{locale}/pages"), locale: /\w\w\w/

  get "pages/:locale/*glob" => redirect("/%{locale}/pages/%{glob}"),
      locale: /\w\w\w/

  # Sitemap
  resource :sitemap, only: [:show]

  namespace :admin do
    get "users/login" => redirect("/admin/login")

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
    resource :account_recovery
    controller :account_recoveries do
      get "/account_recovery/:token" => :show, as: :account_recovery_with_token
    end

    # Attachments
    resources :attachments, only: %i[create update]

    # Images
    resources :images

    # Users
    resources :users do
      collection do
        get "deactivated"
      end
      member do
        delete "delete_image"
      end
    end

    # Authentication
    resource :session, only: %i[create destroy] do
      member { post :verify_otp }
    end
    resource :otp_secret, only: %i[new create destroy]
    resource :recovery_codes, only: %i[new create]
    get "login" => "sessions#new", as: "login"

    # Pages
    scope ":locale" do
      resources :news,
                only: %i[index],
                path: "pages/news(/:year(/:month)(/page/:page))"

      resource :calendar,
               path: "pages/calendar(/:year(/:month)(/page/:page))"

      resources :pages do
        collection do
          get "deleted"
          get "search"
        end

        member do
          put "move"
        end

        get "new/:parent", action: "new"
      end
    end
  end

  # Default admin route
  get("/admin" => redirect do |_env, _req|
                    "/admin/#{I18n.default_locale}/pages/news"
                  end,
      as: "admin_default")

  # Errors
  resources :errors

  # Page path routing
  get ":locale/*path/page/:page" => "pages#show",
      constraints: PagesCore::PagePathConstraint.new

  get ":locale/*path" => "pages#show",
      constraints: PagesCore::PagePathConstraint.new

  get "*path/page/:page" => "pages#show",
      constraints: PagesCore::PagePathConstraint.new,
      defaults: { locale: I18n.default_locale.to_s }

  get "*path" => "pages#show",
      constraints: PagesCore::PagePathConstraint.new,
      defaults: { locale: I18n.default_locale.to_s }

  get "/401", to: "errors#unauthorized"
  get "/403", to: "errors#forbidden"
  get "/404", to: "errors#not_found"
  get "/422", to: "errors#unacceptable"
  get "/500", to: "errors#internal_error"
end
