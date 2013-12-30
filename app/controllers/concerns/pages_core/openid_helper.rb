# encoding: utf-8

module PagesCore
  module OpenidHelper
    extend ActiveSupport::Concern

    # Returns an OpenID consumer, creating it if necessary.
    def openid_consumer
      require 'openid/store/filesystem'
      @openid_consumer ||= OpenID::Consumer.new(
        session,
        OpenID::Store::Filesystem.new(Rails.root.join('tmp', 'openid'))
      )
    end

    # Start an OpenID session
    def start_openid_session(identity_url, options={})
      options[:success] ||= root_path
      options[:fail]    ||= root_path
      session[:openid_redirect_success] = options[:success]
      session[:openid_redirect_fail]    = options[:fail]

      response = openid_consumer.begin(identity_url) rescue nil
      if response #&& response.status == OpenID::SUCCESS
        perform_openid_authentication(response, options)
        return true
      else
        return false
      end
    end

    # Perform OpenID authentication
    def perform_openid_authentication(response, options={})
      options = {
        :url       => complete_openid_url,
        :base_url  => root_url,
        :immediate => false
      }.merge(options)
      redirect_to response.redirect_url(options[:base_url], options[:url], options[:immediate])
    end
  end
end