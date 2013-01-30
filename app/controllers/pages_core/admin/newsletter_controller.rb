# encoding: utf-8

require 'erb'

class PagesCore::Admin::NewsletterController < Admin::AdminController
    include ActionView::Helpers::TextHelper
  include Newsletter

    def render_mailing_template(template_name, options={})
    options = {
      :unsubscribable   => true,
      :unsubscribe_link => unsubscribe_url(:email => options[:recipient])
    }.merge(options)

    @mailer_binding ||= PagesCore::MailerBinding.new(self)
    @mailer_binding.set_instance_variables(options)

    @mailer_binding.call_template_action(template_name)

    template_file = Mailing.template_path(template_name)
    template = ""; File.open(template_file, 'r'){|fh| template = fh.read }
    result = ERB.new(template).result(@mailer_binding.get_binding)
    end

  #def index; redirect_to :action => :compose; end
  def index
    @sort_by = persistent_param :sort_by, 'email'
    sort_clause = { 'group' => '`group` ASC', 'date' => 'created_at DESC', 'email' => 'email ASC' }
    @subscribers = MailSubscriber.find( :all, :order => sort_clause[@sort_by], :conditions => ['unsubscribed = 0'] )
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
        @sender = PagesCore.config.default_sender || "#{@current_user.realname} <#{@current_user.email}>"
    @groups = Mailout.subscriber_groups
    @groups = @groups.collect do |group|
      args = {:distinct => true}
      args[:conditions] = group[:conditions] if group[:conditions]
      group[:count] = group[:class].classify.constantize.count(group[:method], args)
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
    recipient    = @current_user.email
    message      = params[:message]
    message_html = textilize(message)
    if params[:template]
      message = render_mailing_template(
        params[:template],
        :subject      => params[:subject],
        :message      => message,
        :message_html => message_html,
        :recipient    => recipient,
        :sender       => params[:sender]
      )
        end
        render :text => message, :layout => false
    end


  def send_message

    @mailout = Mailout.create(
      :subject  => params[:subject],
      :sender   => params[:sender],
      :body     => params[:message],
      :template => params[:template],
      :image    => params[:image],
      :groups   => params[:send_to].map{|k,v| v == "1" ? k : nil}.compact,
      :host     => (request.port != 80) ? "#{request.host}:#{request.port}" : request.host
    )

    if @mailout.valid?
      @mailout.send_later(:deliver!)
    end


    if false
          @mailout = Mailout.create( :subject => params[:subject], :sender => params[:sender], :body => params[:message], :template => params[:template], :image => params[:image] )

      @groups = @groups.select { |g| params[:send_to][g[:name].underscore.gsub(/[\s]+/,'_')] == "1" }.collect do |group|
        args = Hash.new
        args[:conditions] = group[:conditions] if group[:conditions]
        group[:members] = group[:class].classify.constantize.find( :all, args )
        group
      end

      @recipients  = @groups.collect { |g| g[:members].collect { |m| m[g[:method]] } }.flatten.uniq.compact.sort
      unsubscribed = MailSubscriber.unsubscribed_emails
      sent_to      = []

      message      = params[:message]
      message_html = textilize(message) if params[:template]

      @groups.each do |g|
          g[:members].each do |m|
              recipient = m[g[:method]]
              unless sent_to.include?(recipient) || unsubscribed.include?(recipient)
                  message = params[:message]
                  content_type = "text/plain"
                  if params[:template]
              message = render_mailing_template(
                params[:template],
                :subject      => params[:subject],
                :message      => message,
                :message_html => message_html,
                :recipient    => recipient,
                :sender       => params[:sender],
                :image        => @mailout.image
              )
              content_type = "text/html"
            end
            mailing = Mailing.create( :sender => params[:sender], :recipients => recipient, :subject => params[:subject], :body => message, :content_type => content_type )
          end
        end
      end
    end
  end


end
