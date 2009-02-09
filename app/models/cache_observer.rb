class CacheObserver < ActiveRecord::Observer
	observe PagesCore::CacheSweeper.config.observe

	def clean_cache_for(record)
		if record.kind_of?(Image)
			swept_files = PagesCore::CacheSweeper.sweep_image!(record)
		else
			swept_files = PagesCore::CacheSweeper.sweep!
		end
		record.logger.info "Cleaning cache for #{record.class} ##{record.id}, #{swept_files.length} files deleted." if record.respond_to?(:logger)
	end

	def after_create( record )
		clean_cache_for(record)
	end
	def after_update( record )
		clean_cache_for(record)
	end
	def after_destroy(record)
		clean_cache_for(record)
	end

end
