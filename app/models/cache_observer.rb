class CacheObserver < ActiveRecord::Observer
	observe PagesCore::CacheSweeper.config.observe

	def clean_cache_for(record)
		if !record.respond_to?(:cache_swept)
			class << record
				attr_accessor :cache_swept
			end
			record.cache_swept = false
		end
		if !record.cache_swept
			PagesCore::CacheSweeper.sweep_image!(record) if record.kind_of?(Image)
			PagesCore::CacheSweeper.send_later(:sweep!)
			record.logger.info "Cache sweep queued for later"
			record.cache_swept = true
		end
	end

	def after_create(record)
		clean_cache_for(record)
	end
	def after_update(record)
		clean_cache_for(record)
	end
	def after_destroy(record)
		clean_cache_for(record)
	end

end
