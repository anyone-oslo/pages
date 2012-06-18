# encoding: utf-8

ActionController::Routing::Routes.draw do |map|

	map.dynamic_text '/dynamic_text/:text_format/:text.png', :controller => 'dynamic_text', :action => 'show'

	map.connect 'pages/:language/:id/add_comment',        :controller => 'pages', :action => 'add_comment', :requirements => { :id => /[\d]+.*/ }
	map.connect 'pages/:id',                              :controller => 'pages', :action => 'show', :requirements => { :id => /[\d]+.*/ }
	map.formatted_pages 'pages/:language/index.:format',  :controller => 'pages', :action => 'index'
	map.connect 'pages/:language',                        :controller => 'pages', :action => 'index'
	map.connect 'pages/:language/sitemap.xml',            :controller => 'pages', :action => 'sitemap'
	map.connect 'pages/:language/search',                 :controller => 'pages', :action => 'search'
	map.page    'pages/:language/:id',                    :controller => 'pages', :action => 'show'
	map.page    'pages/:language/:id.rss',                :controller => 'pages', :action => 'show', :format => 'rss'

	map.connect 'pages/:language/:id/:page',              :controller => 'pages', :action => 'show', :requirements => { :page => /[\d]+/ }

	map.connect ':language/pages/:page_id/files/:id',     :controller => 'page_files', :action => 'show'

	map.resources :pages, :path_prefix => '/:language', :collection => {:search => :any, :preview => :any}
	map.resources :page_files, :path_prefix => '/:language/pages/:page_id'


	map.unsubscribe 'newsletter/unsubscribe/*email', :controller => 'newsletter', :action => 'unsubscribe'

	map.resource :openid, :member => { :complete => :get }, :controller => 'openid'

	# Resources for admin
	map.with_options :path_prefix => '/admin', :name_prefix => 'admin_' do |admin|
		admin.resources(
			:images,
			:controller => 'admin/images'
		)
		admin.resources(
			:users,
			:controller => 'admin/users',
			:collection => {:new_password => :any, :welcome => :any, :list => :any, :logout => :any, :login => :any, :deactivated => :any},
			:member     => {:delete_image => :delete, :update_openid => :any}
		)
		admin.resources :accounts, :controller => 'admin/accounts'
		admin.resources(
			:pages,
			:controller  => 'admin/pages',
			:path_prefix => 'admin/:language',
			:collection  => {
				:list          => :any,
				:list_test     => :any,
				:fragment      => :any,
				:new           => :any,
				:news          => :any,
				:new_news      => :any,
				:search        => :any,
				:reorder_pages => :any
			},
			:member      => {
				:delete_language => :any,
				:add_language => :any,
				:preview => :any,
				:delete_comment => :any,
				:add_image => :post,
				:delete_image => :any,
				:delete_presentation_image => :any,
				:update_image_caption => :any,
				:import_xml => :any
			}
		)
		admin.resources(
			:page_images,
			:path_prefix => 'admin/:language/pages/:page_id',
			:controller => 'admin/page_images',
			:collection => {
				:reorder => :put
			}
		)
		admin.resources(
			:page_files,
			:path_prefix => 'admin/:language/pages/:page_id',
			:controller => 'admin/page_files',
			:collection  => { :reorder => :any }
		)
		admin.resources(
			:partials,
			:controller  => 'admin/partials',
			:path_prefix => 'admin/:language',
			:collection  => { :search => :any }
		)
		admin.resources(
			:categories,
			:controller => 'admin/categories'
		)
	end

	map.connect 'admin/pages/new/:parent',                  :controller => 'admin/pages', :action => :new
	map.connect 'admin/:language/pages/reorder/:id/:direction',       :controller => 'admin/pages', :action => 'reorder'
	#connect 'admin/pages/:action/:id/:language',        :controller => 'admin/pages'
	#connect 'admin/pages/:action/:id/:language/:field', :controller => 'admin/pages'

	map.admin_default 'admin',                                   :controller => 'admin/admin', :action => 'redirect'


	map.connect 'xml/:language/:action.:format', :controller => 'xml'

	map.connect 'feeds/:action/:language/:slug/index.xml',  :controller => 'feeds'
	map.connect 'feeds/:action/:language/:slug/:tag.xml',   :controller => 'feeds'

	map.connect 'comments/:action/:type/:id',               :controller => 'comments'

	#map.root :controller => 'pages', :action => 'index'

end