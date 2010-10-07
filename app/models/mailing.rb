class Mailing < ActiveRecord::Base

    before_save do |mailing|
        mailing.content_type ||= 'text/plain'
    end
    
    def self.templates
        unless @cached_templates
            template_dir = File.join(File.dirname(__FILE__), '../../../../../app/views/mailings')
            @cached_templates = Dir.entries(template_dir).select{|f| f =~ /^[^_].*\.[\w]+\.erb$/}.map{|f| f.gsub(/\.[\w]+\.erb$/,'')}.uniq
        end
        return @cached_templates
    end
    
    def self.template_path(template_name)
        template_dir = File.join(File.dirname(__FILE__), '../../../../../app/views/mailings')
        template_file = File.join(template_dir, Dir.entries(template_dir).select{|f| f =~ Regexp.new("^#{template_name}\\.html\\.erb$") }.first)
    end
    
	def self.do_queue
		mailings = self.find(:all, :conditions => ['failed = 0 AND in_progress = 0'])
		unless mailings.empty?
			mailings.each do |mailing|
				begin
					mailing.update_attribute(:in_progress, true)
					Notifications.deliver_newsletter(mailing.sender, mailing.recipients, mailing.subject, mailing.body, mailing.content_type)
					logger.info "Successfully delivered mailing ##{mailing.id} to #{mailing.recipients}"
					mailing.destroy
				rescue Exception => e
					logger.error "Error delivering mailing ##{mailing.id} to #{mailing.recipients}: " + e
					mailing.update_attribute(:failed, true)
				end
			end
		end
	end
end
