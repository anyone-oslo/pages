# encoding: utf-8

class Feed < ActiveRecord::Base

  has_many :feed_items, :order => "id DESC", :dependent => :destroy

  # -- CLASS METHODS --------------------------------------------------------

  # Refresh all feeds. It's a good idea to call this from a cronjob using <tt>script/runner</tt>.
  def self.refresh_feeds
    Feed.find(:all).each{|feed| feed.refresh}
  end

  # Get a feed by url. The feed will be created and loaded if it doesn't exist. This is handy
  # for simple aggregation in templates et al.
  #
  # Example:
  #
  #   <% Feed.url( 'http://blog.anyone.no/index.rss' ).feed_items[0..10].each do |item| -%>
  #     <%= link_to item.title, item.link %>
  #   <% end -%>
  #
  def self.url( url )
    feed = Feed.find( :first, :conditions => [ "url = ?", url ] )
    unless feed
      feed = Feed.new( { :url => url } )
      feed.refresh
    end
    return feed
  end

  # -- INSTANCE METHODS -----------------------------------------------------

  # Refresh feed.
  def refresh
    rss = SimpleRSS.parse open( self.url )

    # Regexp the encoding from the source, assume UTF-8
    encoding = rss.source.match(/encoding="([\-\w]+)"/)[1] rescue "UTF-8"

    # Convert all strings from the source to UTF-8
    converter = Iconv.new( 'utf-8', encoding.downcase )

    self.title       ||= converter.iconv rss.channel.title
    self.link        ||= converter.iconv rss.channel.link
    self.description ||= converter.iconv rss.channel.description

    self.save

    # Items
    rss.items.each do |item|

      # Ensure that a guid is present
      item[:guid] ||= item.link
      item[:guid] ||= item.title
      item[:guid] ||= item.description

      # Is this an existing item or a new one? Uses guid for ad-hoc uniqueness check
      feed_item = self.feed_items.select {|i| i.guid == item[:guid] }.compact.first || FeedItem.new

      self.feed_items << feed_item

      feed_item.guid        = converter.iconv item[:guid]
      feed_item.title       = converter.iconv item[:title]
      feed_item.link        = converter.iconv item[:link]
      feed_item.description = converter.iconv item[:description]
      feed_item.author      = converter.iconv item[:author]
      feed_item.pubdate     = DateTime.parse( item[:pubDate].to_s ) if item[:pubDate]

      feed_item.pubdate ||= Time.now

      feed_item.save
    end

    self.refreshed_at = Time.now
  end

end
