class CacheObserver < ActiveRecord::Observer
	observe PagesCore::CacheSweeper.config.observe

	def clean_cache_for(record)
	  if PagesCore::CacheSweeper.enabled
  		if !record.respond_to?(:cache_swept)
  			class << record
  				attr_accessor :cache_swept
  			end
  			record.cache_swept = false
  		end
  		if !record.cache_swept
  		  puts "Sweeping cache lol"
  			PagesCore::CacheSweeper.sweep_image!(record) if record.kind_of?(Image)
  			PagesCore::CacheSweeper.send_later(:sweep!)
  			record.cache_swept = true
  		end
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
