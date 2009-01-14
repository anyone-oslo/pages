module VideoHelper
	
	VIDEO_FORMATS = {
		:youtube => {
			:detect_expression    => /youtube/,
			:id_expression        => /((v|pl)\/|\?v=)([\w_\-]+)/,
			:id_expression_offset => 3,
			:default_size         => Vector2d.new('425x344'),
			:embed_tag            => "<object width=\"NEW_WIDTH\" height=\"NEW_HEIGHT\"><param name=\"movie\" value=\"http://www.youtube.com/v/VIDEO_ID&rel=1\"></param><param name=\"wmode\" value=\"transparent\"></param><embed src=\"http://www.youtube.com/v/VIDEO_ID&rel=1\" type=\"application/x-shockwave-flash\" wmode=\"transparent\" width=\"NEW_WIDTH\" height=\"NEW_HEIGHT\"></embed></object>"
		},
		:imeem => {
			:detect_expression    => /imeem/,
			:id_expression        => /((v|pl)\/|\?v=)([\w_\-]+)/,
			:id_expression_offset => 3,
			:default_size         => Vector2d.new('460x390'),
			:embed_tag            => "<object width=\"NEW_WIDTH\" height=\"NEW_HEIGHT\"><param name=\"movie\" value=\"http://media.imeem.com/v/VIDEO_ID/aus=false/pv=2\"></param><param name=\"allowFullScreen\" value=\"true\"></param><embed src=\"http://media.imeem.com/v/VIDEO_ID/aus=false/pv=2\" type=\"application/x-shockwave-flash\" width=\"NEW_WIDTH\" height=\"NEW_HEIGHT\" allowFullScreen=\"true\"></embed></object>"
		},
		:myspace => {
			:detect_expression    => /myspace/,
			:id_expression        => /(\/m|videoid)=([\d]+)/,
			:id_expression_offset => 2,
			:default_size         => Vector2d.new('425x360'),
			:embed_tag            => "<object width=\"NEW_WIDTH\" height=\"NEW_HEIGHT\"><param name=\"movie\" value=\"http://mediaservices.myspace.com/services/media/embed.aspx/m=VIDEO_ID,t=1,mt=video\"></param><param name=\"allowFullScreen\" value=\"true\"></param><embed src=\"http://mediaservices.myspace.com/services/media/embed.aspx/m=VIDEO_ID,t=1,mt=video\" type=\"application/x-shockwave-flash\" width=\"NEW_WIDTH\" height=\"NEW_HEIGHT\" allowFullScreen=\"true\"></embed></object>"
		},
		:vimeo => {
			:detect_expression    => /vimeo/,
			:id_expression        => /(vimeo\.com\/|clip_id=)([\d]+)/,
			:id_expression_offset => 2,
			:default_size         => Vector2d.new('400x321'),
			:embed_tag            => "<object width=\"NEW_WIDTH\" height=\"NEW_HEIGHT\"><param name=\"allowfullscreen\" value=\"true\" /><param name=\"allowscriptaccess\" value=\"always\" /><param name=\"movie\" value=\"http://vimeo.com/moogaloop.swf?clip_id=VIDEO_ID&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=0&amp;show_portrait=0&amp;color=&amp;fullscreen=1\" /><embed src=\"http://vimeo.com/moogaloop.swf?clip_id=VIDEO_ID&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=0&amp;show_portrait=0&amp;color=&amp;fullscreen=1\" type=\"application/x-shockwave-flash\" allowfullscreen=\"true\" allowscriptaccess=\"always\" width=\"NEW_WIDTH\" height=\"NEW_HEIGHT\"></embed></object>"
		}
	}
	
	# Embed a video, optionally resizing the object. The height
	# will be calculated to the proper aspect ratio if :height is omitted.
	# The video can be an URL or an embed tag.
	def video_embed(video, options={})
		# Detect format
		if options[:format]
			format         = options[:format]
			format_options = VIDEO_FORMATS[format.to_sym]
		else
			format         = nil
			format_options = nil
			VIDEO_FORMATS.each do |name, toptions| 
				if video =~ toptions[:detect_expression] 
					format         = name
					format_options = toptions
				end
			end
		end
		return video unless format # Return the video as a failsafe if the format isn't detected

		# Detect id
		id = video_id(video, format)

		# Detect dimensions
		original_width, original_height = detect_video_dimensions(video)
		original_width  ||= format_options[:default_size].x
		original_height ||= format_options[:default_size].y
		
		# Resized dimensions
		if options[:width] && options[:height]
			new_width, new_height = options[:width].to_i, options[:height].to_i
		elsif options[:width]
			new_width, new_height = options[:width].to_i, ((options[:width].to_f / original_width.to_f) * original_height)
		elsif options[:height]
			new_width, new_height = ((options[:height].to_f / original_height.to_f) * original_width), options[:height].to_i
		else
			new_width, new_height = original_width, original_height
		end

		# Create embed tag
		embed_tag = format_options[:embed_tag].dup
		embed_tag.gsub!(/VIDEO_ID/, id)
		embed_tag.gsub!(/NEW_WIDTH/, new_width.round.to_i.to_s)
		embed_tag.gsub!(/NEW_HEIGHT/, new_height.round.to_i.to_s)
		return embed_tag
	end
	
	# Convert video embed tag or URL to ID.
	def video_id(id, format)
		id_expression = VIDEO_FORMATS[format.to_sym][:id_expression]
		if id =~ id_expression
			id = id.match(id_expression)[VIDEO_FORMATS[format.to_sym][:id_expression_offset]]
		end
		id
	end
	
	# Detect default video dimensions from an embed tag.
	def detect_video_dimensions(embed)
		width  = embed.match(/width="?([\d]+)"?/)[1].to_f  if embed =~ /width="?([\d]+)"?/
		height = embed.match(/height="?([\d]+)"?/)[1].to_f if embed =~ /height="?([\d]+)"?/
		[width, height]
	end

	def youtube_id(id); video_id(id, :youtube); end
	def imeem_id(id);   video_id(id, :imeem);   end
	def myspace_id(id); video_id(id, :myspace); end
	def vimeo_id(id);   video_id(id, :vimeo);   end
	
	def youtube_embed(video, options={}); video_embed(video, options.merge({:format => :youtube})); end
	def imeem_embed(video, options={});   video_embed(video, options.merge({:format => :imeem}));   end
	def myspace_embed(video, options={}); video_embed(video, options.merge({:format => :myspace})); end
	def vimeo_embed(video, options={});   video_embed(video, options.merge({:format => :vimeo}));   end
	
end