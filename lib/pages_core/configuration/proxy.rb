module PagesCore
	module Configuration
		class Proxy
			def initialize(callback, parent=nil)
				@callback = callback
				@parent = parent
			end
			def method_missing(method_name, *args, &block)
				if @parent
					(block_given?) ? @callback.call(@parent, method_name, block) : @callback.call(@parent, method_name, *args)
				else
					(block_given?) ? @callback.call(method_name, block) : @callback.call(method_name, *args)
				end
			end
		end
	end
end