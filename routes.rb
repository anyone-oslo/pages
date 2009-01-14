
dynamic_text '/dynamic_text/:text_format/:text.png', :controller => 'dynamic_text', :action => 'show'

connect '',                                       :controller => 'pages', :action => 'index'
connect 'pages/:language/:id/add_comment',        :controller => 'pages', :action => 'add_comment', :requirements => { :id => /[\d]+.*/ }
connect 'pages/:id',                              :controller => 'pages', :action => 'show', :requirements => { :id => /[\d]+.*/ }
connect 'pages/:language',                        :controller => 'pages', :action => 'index'
connect 'pages/:language/sitemap.xml',            :controller => 'pages', :action => 'sitemap'
connect 'pages/:language/search',                 :controller => 'pages', :action => 'search'
page    'pages/:language/:id',                    :controller => 'pages', :action => 'show'
page    'pages/:language/:id.rss',                :controller => 'pages', :action => 'show', :format => 'rss'

connect 'pages/:language/:id/:page',              :controller => 'pages', :action => 'show'

connect ':language/pages/:page_id/files/:id',     :controller => 'page_files', :action => 'show'

resources :pages, :path_prefix => '/:language'
resources :page_files, :path_prefix => '/:language/pages/:page_id'


# Resources for admin
with_options :path_prefix => '/admin', :name_prefix => 'admin_' do |admin|
	admin.resources( 
		:users,    
		:controller => 'admin/users', 
		:collection => { :new_password => :any, :welcome => :any, :list => :any, :logout => :any },
		:member     => { :delete_image => :delete }
	)
	admin.resources :accounts, :controller => 'admin/accounts'
	admin.resources( 
		:pages,
		:controller  => 'admin/pages', 
		:path_prefix => 'admin/:language',
		:collection  => { :list => :any, :list_test => :any, :fragment => :any, :new => :any, :news => :any },
		:member      => { :delete_language => :any, :add_language => :any, :preview => :any, :delete_comment => :any, :add_image => :post, :delete_image => :any, :delete_presentation_image => :any }
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

connect 'admin/pages/new/:parent',                  :controller => 'admin/pages', :action => :new
connect 'admin/pages/reorder/:id/:direction',       :controller => 'admin/pages', :action => 'reorder'
#connect 'admin/pages/:action/:id/:language',        :controller => 'admin/pages'
#connect 'admin/pages/:action/:id/:language/:field', :controller => 'admin/pages'

connect 'admin/',                                   :controller => 'admin/pages'


connect 'feeds/:action/:language/:slug/index.xml',  :controller => 'feeds'
connect 'feeds/:action/:language/:slug/:tag.xml',   :controller => 'feeds'

connect 'comments/:action/:type/:id',               :controller => 'comments'
