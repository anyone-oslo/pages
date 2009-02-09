require 'find'
module PagesCore
	class CacheSweeper
		class << self

			# Returns the default configuration.
			def default_config
				default = MethodedHash.new
				default[:cache_path] = File.join(File.dirname(__FILE__), '../../../../../public/cache')
				default[:observe]    = [Page, FeedItem, Feed, PageComment, Partial, Image]
				default[:patterns]   = [/^\/index\.[\w]+$/, /^\/pages\/[\w]{3}\/(.*)$/, /^\/[\w]{3}\/(.*)$/]
				default
			end

			# Returns the configuration. Accepts a block, ie:
			#
			#   PagesCore::CacheSweeper.config do |c|
			#     c.observe  += [Store, StoreTest]
			#     c.patterns += [/^\/arkiv(.*)$/, /^\/tests(.*)$/]
			#   end
			def config
				@@configuration ||= self.default_config
				yield @@configuration if block_given?
				@@configuration
			end

			# Sweep all cached pages
			def sweep!
				#languages = %w{nor eng}
				cache_dir = self.config.cache_path
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

			# Sweep cached dynamic image
			def sweep_image!(image_id)
				image_id = image_id.id if image_id.kind_of?(Image)
				cache_dir = self.config.cache_path
				image_dir = File.join(cache_dir, "dynamic_image/#{image_id}")
				swept_files = []
				if File.exist?(cache_dir) && File.exist?(image_dir)
					Find.find( image_dir+"/" ) do |path|
						if File.file?(path)
							swept_files << path
							`rm -rf #{path}`
						end
					end
				end
				[]
			end
		end
	end
end