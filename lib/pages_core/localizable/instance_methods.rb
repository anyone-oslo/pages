module Localizable

  module InstanceMethods
    def localizer
      @localizer ||= Localizer.new(self)
    end

    def locale
      self.localizer.locale
    end

    def locale=(locale)
      self.localizer.locale = locale
    end

    def translate(locale, options={})
      dupe = self.dup.translate!(locale, options)
      (block_given?) ? (yield dupe) : dupe
    end

    def translate!(locale, options={})
      self.localizer.locale = locale
      self
    end

    def cleanup_localizations!
      self.localizer.cleanup_localizations!
    end

    # Overrides ActiveRecord#attributes= to catch locale before
    # attributes are written.
    def attributes=(new_attributes, guard_protected_attributes=true)
      return unless new_attributes.is_a?(Hash)
      attributes = new_attributes.stringify_keys
      self.locale = attributes['language'] if attributes.has_key?('language')
      self.locale = attributes['locale']   if attributes.has_key?('locale')
      super
    end

    def respond_to?(method_name, *args)
      requested_attribute, request_type = method_name.to_s.match( /(.*?)([\?=]?)$/ )[1..2]
      localizer.has_attribute?(requested_attribute.to_sym) ? true : super
    end

    def method_missing(method_name, *args)
      requested_attribute, request_type = method_name.to_s.match( /(.*?)([\?=]?)$/ )[1..2]
      if localizer.has_attribute?(requested_attribute.to_sym)
        case request_type
        when "?"
          localizer.has_value_for?(requested_attribute.to_sym)
        when "="
          localizer.set(requested_attribute.to_sym, args.first)
        else
          localizer.get(requested_attribute.to_sym)
        end
      else
        super
      end
    end

    alias :working_language  :locale
    alias :working_language= :locale=
  end

end
