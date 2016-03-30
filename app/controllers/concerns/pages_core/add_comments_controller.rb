# encoding: utf-8

module PagesCore
  module AddCommentsController
    extend ActiveSupport::Concern

    # Add a comment to a page. Recaptcha is performed if
    # PagesCore.config(:recaptcha) is set.
    def add_comment
      @comment = new_comment(@page)

      unless captcha_verified?
        @comment.invalid_captcha = true
        render_page
        return
      end

      return unless @page.comments_allowed? && !honeypot_triggered?

      @comment.save
      deliver_comment_notifications(@page, @comment)
      redirect_to(page_url(@locale, @page))
    end

    private

    def captcha_verified?
      !PagesCore.config(:recaptcha) || verify_recaptcha
    end

    def comment_recipients(page)
      PagesCore.config(:comment_notifications)
               .map { |r| r == :author ? page.author.name_and_email : r }
               .uniq
    end

    def deliver_comment_notifications(page, comment)
      return unless PagesCore.config(:comment_notifications)
      comment_recipients(page).each do |r|
        AdminMailer.comment_notification(
          r,
          page,
          comment,
          page_url(locale, page)
        ).deliver_now
      end
    end

    def honeypot_triggered?
      PagesCore.config(:comment_honeypot) && !params[:email].to_s.empty?
    end

    def new_comment(page)
      PageComment.new(
        page_comment_params.merge(remote_ip: remote_ip, page_id: page.id)
      )
    end

    def page_comment_params
      params.require(:page_comment).permit(:name, :email, :url, :body)
    end

    def remote_ip
      request.env["REMOTE_ADDR"]
    end
  end
end
