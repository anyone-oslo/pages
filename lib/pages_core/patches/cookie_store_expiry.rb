# encoding: utf-8

# Monkey patch CGI::Session::CookieStore to default session expiry
# to 3 years into the future.
class CGI::Session::CookieStore
	alias_method :original_write_cookie, :write_cookie
    def write_cookie(options)
		options['expires'] ||= 3.years.from_now
		original_write_cookie(options)
	end
end