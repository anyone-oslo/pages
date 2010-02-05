class NewsletterController < ApplicationController

	def subscribe
		email = [params[:email]].flatten.first rescue nil
		if email
			if params[:group]
				MailSubscriber.subscribe(email, params[:group])
			else
				MailSubscriber.subscribe(email)
			end
		end
		flash[:notice] = "You have subscribed to our newsletter."
		redirect_back_or_to "/"
	end
	
	def unsubscribe
		email = [params[:email]].flatten.first rescue nil
		if email
			MailSubscriber.unsubscribe(email)
		end
		flash[:notice] = "You have unsubscribed from our newsletter."
		redirect_back_or_to "/"
	end

end