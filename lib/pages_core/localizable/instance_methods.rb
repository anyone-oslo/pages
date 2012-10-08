module PagesCore
  module Localizable

    # = Localizable::InstanceMethods
    #
    # This is the public API for all localizable models.
    # See Localizable for usage examples.
    #
    module InstanceMethods

      # Getter for locale
      #
      #  page.locale # => 'en'
      #
      def locale
        self.localizer.locale
      end

      # Getter for locale
      #
      #  page.locale = 'no' # => 'no'
      #
      def locale=(locale)
        self.localizer.locale = locale
      end

      # Returns a copy of the model with a different locale.
      #
      #  localized = page.localize('en')
      #
      # localize also takes a block as an argument, which returns the
      # result of the block.
      #
      #  page.localize('nb') do |p|
      #    p.locale # => 'nb'
      #  end
      #  page.locale # => 'en'
      #
      def localize(locale)
        clone = self.clone.localize!(locale)
        (block_given?) ? (yield clone) : clone
      end

      # In-place variant of #localize.
      #
      #  page.localize!('en')
      #
      # This is functionally equivalent to setting locale=,
      # but returns the model instead of the locale and is chainable.
      #
      def localize!(locale)
        self.localizer.locale = locale
        self
      end

      # assign_attributes from ActiveRecord is overridden to catch locale before
      # any other attributes are written. This enables the following construct:
      #
      #  Page.create(:name => 'My Page', :locale => 'en')
      #
      def assign_attributes(new_attributes, options={})
        if new_attributes.is_a?(Hash)
          attributes = new_attributes.stringify_keys
          self.locale = attributes['language'] if attributes.has_key?('language')
          self.locale = attributes['locale']   if attributes.has_key?('locale')
        end
        super
      end

      # A localized model responds to :foo, :foo= and :foo?
      #
      def respond_to?(method_name, *args)
        requested_attribute, request_type = method_name.to_s.match( /(.*?)([\?=]?)$/ )[1..2]
        localizer.has_attribute?(requested_attribute.to_sym) ? true : super
      end

      alias :translate  :localize
      alias :translate! :localize!
      alias :working_language  :locale
      alias :working_language= :locale=

      protected

        # Getter for the model's Localizer.
        #
        def localizer
          @localizer ||= Localizer.new(self)
        end

        # Callback for cleaning up empty localizations.
        # This is performed automatically when the model is saved.
        #
        def cleanup_localizations!
          self.localizer.cleanup_localizations!
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

    end
  end
end
