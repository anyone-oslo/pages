# encoding: utf-8

module PagesCore
	# The Paginates module adds syntactic sugar to a collection for handling pagination.
	# The module doesn't do any pagination on it's own, the logic should be handled by the finders.
	#
	# Example:
	#   @users = User.find(:all, :limit => 20, :offset => 20)
	#   PagesCore::Paginates.paginate(@users, :current_page => 2, :pages => 5, :per_page => 20)
	#
	# Now, in the view, you could do:
	#
	#   <%= link_to_unless @pages.first_page? "Previous page", {:page => @users.previous_page}  %>
	#   <% @users.pages.each do |p| %>
	#     <%= link_to_unless p == @users.current_page, p, {:page => p} %>
	#   <% end %>
	#   <%= link_to_unless @pages.last_page? "Next page", {:page => @users.next_page}  %>
	module Paginates
		attr_accessor :paginated, :current_page, :pages, :per_page, :offset

		class << self
			# Applies pagination to any collection.
			def paginate(collection, options={})
				options[:current_page] ||= 1
				options[:pages]        ||= 1
				options[:per_page]     ||= nil
				options[:offset]       ||= 0
				class << collection
					include PagesCore::Paginates
				end
				collection.current_page = options[:current_page]
				collection.pages        = options[:pages]
				collection.per_page     = options[:per_page]
				collection.offset       = options[:offset]
				collection.paginated    = options[:per_page] ? true : false
			end
		end

		# Returns true if collection is paginated
		def paginated?
			(@paginated) ? true : false
		end

		# Returns next page, or nil if at last page.
		def next_page
			(@current_page < @pages) ? (@current_page + 1) : nil
		end

		# Returns true/false depending on if there's a next page
		def next_page?
			(self.next_page) ? true : false
		end

		# Returns previous page, or nil if at first page.
		def previous_page
			(@current_page > 1) ? (@current_page - 1) : nil
		end

		# Returns true/false depending on if there's a previous page
		def previous_page?
			(self.previous_page) ? true : false
		end

		# Number of pages
		def last_page
			@pages
		end

		# Returns true if at the last page
		def last_page?
			(@page == @pages) ? true : false
		end

		# First page
		def first_page
			1
		end

		# Returns true if at the first page
		def first_page?
			(@page == 1) ? true : false
		end

		# All pages as an array
		def pages
			(self.first_page..self.last_page).to_a
		end

	end
end


