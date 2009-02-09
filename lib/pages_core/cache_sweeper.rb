require 'find'
module PagesCore
	class CacheSweeper
		class << self
			def default_config
				default = MethodedHash.new
				default[:cache_path] = File.join(File.dirname(__FILE__), '../../../../../public/cache')
				default[:observe]    = [Page, FeedItem, Feed, PageComment, Partial]
				default[:patterns]   = [/^\/index\.[\w]+$/, /^\/pages\/[\w]{3}\/(.*)$/, /^\/[\w]{3}\/(.*)$/]
				default
			end
			def config
				@@configuration ||= self.default_config
				yield @@configuration if block_given?
				@@configuration
			end
			def sweep!
				#languages = %w{nor eng}
				cache_dir = File.join(File.dirname(__FILE__), '..', 'public', 'cache')
				swept_files = []
				if File.exist?(cache_dir) && PagesCore.config(:page_cache)
					kill_patterns = self.config.patterns
					paths = []
					Find.find( cache_dir+"/" ) do |path|
						file = path.gsub( Regexp.new("^#{cache_dir}"), "" )
						kill_patterns.each do |p|
							if file =~ p && File.exist?( path )
								swept_files << path
								`rm -rf #{path}`
							end
						end
					end
				end
				return swept_files
			end
		end
	end
end