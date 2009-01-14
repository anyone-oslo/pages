require 'erb'

class MailerBinding
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::AssetTagHelper
    include ApplicationHelper
    def initialize(controller, subject, message, sender, recipient, unsubscribable, image=nil)
        @controller = controller
        @subject, @message, @sender, @recipient, @unsubscribable, @image = subject, message, sender, recipient, unsubscribable, image
        @message_html = textilize(@message)
    end
    def get_binding
        binding
    end
end

class Admin::NewsletterController < Admin::AdminController
	include Newsletter
	
    def get_groups
	    @groups = []
	    MailSubscriber.groups.each do |group_name|
    	    @groups << {:name => "Subscribers: #{group_name}", :class => "MailSubscriber", :method => :email, :conditions => ['`group` = ?', group_name]}
        end
	    @groups = (@groups + Newsletter::subscriber_groups).uniq
	    #raise @groups.inspect
    end
    protected     :get_groups
    before_filter :get_groups, :only => [:compose, :send_message]
    
    def render_mailing_template(subject, message, sender, recipient, template_file, unsubscribable, image=nil)
        b = MailerBinding.new(self, subject, message, sender, recipient, unsubscribable, image)
        template = ""; File.open(template_file, 'r'){|fh| template = fh.read }
        result = ERB.new(template).result(b.get_binding)
    end

	#def index; redirect_to :action => :compose; end
	def index
		@sort_by = persistent_param :sort_by, 'email'
		sort_clause = { 'group' => '`group` ASC', 'date' => 'created_at DESC', 'email' => 'email ASC' }
		@subscribers = MailSubscriber.find( :all, :order => sort_clause[@sort_by] )
	end
	
	def status
        @pending = Mailing.find(:all, :conditions => 'failed = 0', :order => 'created_at DESC')
	    @failed  = Mailing.find(:all, :conditions => 'failed = 1', :order => 'created_at DESC')
    end
	
	def import
    end
	

	def csv_export
		if params[:group]
			@subscribers = MailSubscriber.find( :all, :order => "created_at", :conditions => ["`group` = ?", params[:group]] )
		else
			@subscribers = MailSubscriber.find( :all, :order => "created_at" )
		end
		text = @subscribers.map{|s| [ s.email, s.group, s.created_at ].join(",") }.join("\n")
		send_data( 
			text, 
			:filename    => "mail_subscribers.csv", 
			:type        => "application/csv", 
			:disposition => 'inline'
			#:disposition => 'attachment'
		)
	end

	def compose
        @sender = Pages.config(:default_sender) || "#{@current_user.realname} <#{@current_user.email}>"
		@groups = @groups.collect do |group|
			args = { :distinct => true }
			args[:conditions] = group[:conditions] if group[:conditions]
			group[:count] = group[:class].classify.constantize.count( group[:method], args )
			group
		end
	end
	
	def create
	    emails = params[:subscriber][:email].split
	    group = (params[:new_group] && !params[:new_group].empty?) ? params[:new_group] : params[:subscriber][:group]
        emails.each do |email|
    		@new_subscriber = MailSubscriber.create( params[:subscriber].merge({ :email => email, :group => group }) )
        end
		if emails.length > 1
			flash[:notice] = "New subscribers added"
		else
			flash[:notice] = "#{emails.first} added"
		end
		redirect_to :action => :index
	end
	
	def destroy
		@subscriber = MailSubscriber.find( params[:id] ) rescue nil
		if @subscriber
			flash[:notice] = "Subscriber <em>#{@subscriber.email}</me> deleted."
			@subscriber.destroy
		end
		redirect_to :action => :index
	end
	
	def preview
        recipient = @current_user.email
        message = params[:message]
        if params[:template]
            message = render_mailing_template(params[:subject], message, params[:sender], recipient, Mailing.template_path(params[:template]), true)
        end
        render :text => message, :layout => false
    end
	

	def send_message
        @mailout = Mailout.create( :subject => params[:subject], :sender => params[:sender], :body => params[:message], :template => params[:template], :image => params[:image] )
	    
		@groups = @groups.select { |g| params[:send_to][g[:name].underscore.gsub(/[\s]+/,'_')] == "1" }.collect do |group|
			args = Hash.new
			args[:conditions] = group[:conditions] if group[:conditions]
			group[:members] = group[:class].classify.constantize.find( :all, args )
			group
		end
		
		@recipients = @groups.collect { |g| g[:members].collect { |m| m[g[:method]] } }.flatten.uniq.compact.sort
		sent_to = []
		@groups.each do |g|
		    g[:members].each do |m|
		        recipient = m[g[:method]]
		        unless sent_to.include?(recipient)
		            message = params[:message]
		            content_type = "text/plain"
		            if params[:template]
		                message = render_mailing_template(params[:subject], message, params[:sender], recipient, Mailing.template_path(params[:template]), (m.kind_of?(MailSubscriber) ? true : false), @mailout.image)
		                content_type = "text/html"
	                end
            		mailing = Mailing.create( :sender => params[:sender], :recipients => recipient, :subject => params[:subject], :body => message, :content_type => content_type )
	            end
	        end
	    end
		
		#@recipients.each do |r|
		#	mailing = Mailing.create( :sender => params[:sender], :recipients => r, :subject => params[:subject], :body => params[:message] )
			#begin
			#	Notifications.deliver_newsletter( @current_user, "inge+test@manualdesign.no", params[:subject], params[:message] )
			#	#Notifications.deliver_newsletter( @current_user, r, params[:subject], params[:message] )
			#rescue
			#	logger.info "Could not deliver to recipient "+r
			#end
		#end
		#@recipients.in_groups_of( 100 ) do |recipients_slice|
		#	raise recipients_slice.inspect
		#	#Notifications.deliver_newsletter( @current_user, recipients_slice, params[:subject], params[:message] )
		#end
	end
	
	
end
