module FrontendHelper
	def formatted_date(date, options={})
		date = date.to_date
		options.symbolize_keys!

		return "Today"[] if date == Date.today
		return "Yesterday"[] if date == Time.now.yesterday.to_date

		options[:include_day] ||= false
		options[:short_month], options[:short_day] = true if options[:short]
		if @language.to_s == 'nor'
			months = ( !options[:short_month] ) ? %w{Januar Februar Mars April Mai Juni Juli August September Oktober November Desember} : %w{Jan Feb Mar Apr Mai Jun Jul Aug Sep Okt Nov Des}
			days   = ( !options[:short_day] )   ? %w{Mandag Tirsdag Onsdag Torsdag Fredag Lørdag Søndag} : %w{Man Tir Ons Tor Fre Lør Søn}
		else
			months = ( !options[:short_month] ) ? %w{January February March April May June July August September October November December} : %w{Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec}
			days   = ( !options[:short_day] )   ? %w{Monday Tuesday Wednesday Thursday Friday Saturday Sunday} : %w{Mon Tue Wed Thu Fri Sat Sun}
		end
		days   = days.map{ |d| d.downcase } unless options[:capitalize_day]

		output  = ""
		output += days[(date.strftime( "%w" ).to_i)]+" " if options[:include_day]
		output += date.strftime( "%d. " ) + months[(date.strftime("%m").to_i-1)]
		output += date.strftime( " %Y" ) if date.strftime( "%Y" ) != Time.now.strftime( "%Y" ) || options[:include_year]
		output
	end
	
	def formatted_time(time, options={})
		f = formatted_date(time, options)
		f += time.strftime( ", %Y" ) if time.strftime("%Y") == Time.now.strftime("%Y")
		f
	end

	def nav_link(page)
		link_to page.name.to_s.upcase, page_url(page) #:controller => :pages, :action => :show, :id => page
	end

	def nav_list_item(page, options={})
	    options[:selected_class] ||= 'selected'
        if page.redirects? && page.redirect_to_options.kind_of?(Hash) && page.redirect_to_options[:controller] == params[:controller]
			"<li class=\"#{options[:selected_class]}\">#{nav_link(page)}</li>"
		elsif @page && page.is_or_is_ancestor?(@page)
			"<li class=\"#{options[:selected_class]}\">#{nav_link(page)}</li>"
		else
			"<li>#{nav_link(page)}</li>"
		end
	end
end