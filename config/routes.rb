# encoding: utf-8

Rails.application.routes.draw do

	# DynamicText
	match '/dynamic_text/:text_format/:text.png' => 'dynamic_text#show', :as => 'dynamic_text'

	# Pages
	resources :pages, :path => '/pages/:language' do
		collection do
			get  'search'
			post 'search'
			post 'preview'
			get  'sitemap'
		end
		member do
			post 'add_comment'
		end
		resources :page_files
	end
	match '/pages/:language/:id/:page' => 'pages#show', :constraints => { :page => /\d+/ }

	# OpenID
	resource :openid, :controller => 'openid' do
		member do
			get 'complete'
		end
	end

	namespace :admin do

		# Accounts
		resources :accounts

		# Images
		resources :images

		# Users
		resources :users do
			collection do
				get  'new_password'
				post 'reset_password'
				get  'welcome'
				post 'create_first'
				get  'login'
				post 'login'
				get  'logout'
			end
			member do
				delete 'delete_image'
				get 'update_openid'
			end
		end

		# Categories
		resources :categories

		# Pages
		scope ":language" do
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
						get 'reorder'
					end
				end
			end
		end

	end

	# Default admin route
	match '/admin' => redirect{"/admin/#{Language.default}/pages/news"}, :as => 'admin_default'
	#match '/admin' => 'admin#redirect', :as => 'admin_default'

	# Legacy routes
	match '/xml/:language/:action', :controller => 'xml'
	match '/comments/:action/:type/:id', :controller => 'comments'

end