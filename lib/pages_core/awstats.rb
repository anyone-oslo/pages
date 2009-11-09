class PagesCore::AWStats
	
	attr_accessor :domain, :script, :month, :year
	attr_reader   :last_update, :unique_visitors, :pages, :hits, :visits_per_day, :bandwidth
	
	def initialize( domain, options={} )
		options = {
			:year  => Time.now.year,
			:month => Time.now.month
		}.merge( options )
		@domain = domain
		@year = options[:year]
		@month = options[:month]
		@script = "http://server.manualdesign.no/cgi-bin/awstats.pl"
		self.load_stats!
	end
	
	def load_stats!
		@url = "#{@script}?config=#{@domain}&framename=mainright&year=#{year}&month=#{month}"
		stats_doc = Hpricot( open( @url ) )
		
		@last_update     = ( stats_doc / "td.aws/span" )[0].inner_html rescue Time.now
		
		@unique_visitors = ( stats_doc / "td/b" )[5].inner_html.to_i rescue 0
		@pages           = ( stats_doc / "td/b" )[7].inner_html.to_i rescue 0
		@hits            = ( stats_doc / "td/b" )[8].inner_html.to_i rescue 0

		bw = ( stats_doc / "td/b" )[9].inner_html rescue "0 KB"
		bw, multiplier = bw.strip.downcase.match( /^([\d\.]+) ([\w]+)$/ )[1..2]
		multiplier = { "b" => 1, "kb" => (1024), "mb" => (1024**2), "gb" => (1024**3), "tb" => (1024**4) }[multiplier]
		@bandwidth = ( bw.to_f * multiplier ).to_i
		

		@visits_per_day  = ( stats_doc / "img" ).map do |img|
			match_data = img.attributes['alt'].match( /^Number of visits: ([\d]+)/ )
			(match_data) ? match_data[1].to_i : nil
		end.compact[12..-2]
	end
	
	def projected_bandwidth
		return @bandwidth unless ( @year.to_i == Time.now.year && @month.to_i == Time.now.month )
		total_days = [31,28,31,30,31,30,31,31,30,31,30,31][(@month.to_i-1)]
		( ( @bandwidth / Time.now.day ) * total_days )
	end
	
end
