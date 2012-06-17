# encoding: utf-8

module ActionController

	# Monkey patch for fixing file upload breakage
	class CgiResponse
		def out_with_espipe(*args)
			begin
				out_without_espipe(*args)
			rescue Errno::ESPIPE => exception
				File.open(File.join(File.dirname(__FILE__), '../../../../log/cgiresponse.log'), 'a'){|fh| fh.write(exception.to_s)} rescue nil
				begin
					message    = exception.to_s + "\r\n" + exception.backtrace.join("\r\n")
					RAILS_DEFAULT_LOGGER.fatal(message)
				rescue Exception => e
					$stderr.write("Exception #{e.to_s} in handling exception #{exception.to_s}")
				end
			end
		end
		alias_method_chain :out, :espipe
	end
end