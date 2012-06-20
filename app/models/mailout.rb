# encoding: utf-8

class Mailout < ActiveRecord::Base
	include ActionController::UrlWriter
	include ActionView::Helpers::TextHelper

	belongs_to_image :image
	serialize :groups, Array

	class << self
		def subscriber_groups
			groups = []
			MailSubscriber.groups.each do |group_name|
				groups << {:name => "Subscribers: #{group_name}", :class => "MailSubscriber", :method => :email, :conditions => ['`group` = ?', group_name]}
			end
			groups = (groups + Newsletter::subscriber_groups).uniq
			groups = groups.map do |group|
				group[:id] = group[:name].underscore.gsub(/[\s]+/,'_')
				group
			end
			groups
		end

		def templates
			unless @cached_templates
				template_dir = Rails.root.join('app', 'views', 'mailings')
				@cached_templates = Dir.entries(template_dir).select{|f| f =~ /^[^_].*\.[\w]+\.erb$/}.map{|f| f.gsub(/\.[\w]+\.erb$/,'')}.uniq
			end
			return @cached_templates
		end

		def template_path(template_name)
			template_dir = Rails.root.join('app', 'views', 'mailings')
			template_file = File.join(template_dir, Dir.entries(template_dir).select{|f| f =~ Regexp.new("^#{template_name}\\.html\\.erb$") }.first)
		end
	end

	def recipients
		# Find recipients
		subscriber_groups = self.groups.map{|g| self.class.subscriber_groups.select{|sg| sg[:id] == g }.first rescue nil}.compact
		recipients = []
		subscriber_groups.each do |group|
			args = Hash.new
			args[:conditions] = group[:conditions] if group[:conditions]
			members = group[:class].classify.constantize.find(:all, args)
			recipients += members.collect{|m| m[group[:method]]}
		end
		recipients = recipients.compact.map{|r| r.strip}.uniq.sort

		# Remove unsubscribed
		unsubscribed = MailSubscriber.unsubscribed_emails
		recipients.reject!{|r| unsubscribed.include?(r)}
		recipients
	end

		def rendered_template(recipient, options={})
		options = {
			:unsubscribable   => true,
			:unsubscribe_link => url_for(hash_for_unsubscribe_path(:email => recipient).merge(:host => self.host, :only_path => false)),
			:subject          => self.subject,
			:message          => self.body,
			:message_html     => textilize(self.body),
			:image            => self.image,
			:host             => self.host
		}.merge(options)

		unless @mailer_binding
			@mailer_binding = PagesCore::MailerBinding.new(self)
		end
		@mailer_binding.set_instance_variables(options)
		@mailer_binding.call_template_action(self.template)

		unless @template_file
			@template_file = ""
			File.open(Mailout.template_path(self.template), 'r'){|fh| @template_file = fh.read }
		end
		renderer = ERB.new(@template_file)
		result = renderer.result(@mailer_binding.get_binding)
		end

	def deliver!
		recipients.each do |r|
			begin
				Notifications.deliver_newsletter(self.sender, r, self.subject, rendered_template(r), "text/html")
			rescue
				# Do nothing
			end
		end
	end
end