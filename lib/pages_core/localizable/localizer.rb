module Localizable

  class Localizer
    attr_accessor :locale
    def initialize(model)
      @model                 = model
      @configuration         = model.class.localizable_configuration
      @unsaved_localizations = []
    end

    def has_attribute?(attribute)
      @configuration.has_attribute?(attribute)
    end

    def locale?
      locale ? true : false
    end

    def get(attribute)
      localizations = @model.localizations.select{|l| l.name == attribute.to_s && l.locale == locale.to_s}
      localizations.length > 0 ? localizations.first : nil
    end

    def set_with_locale(set_locale, attribute, value)
      unless set_locale
        raise ArgumentError, "Tried to set :#{attribute}, but no locale has been set"
      end
      unless localization = get(attribute)
        localization = @model.localizations.new(:locale => set_locale.to_s, :name => attribute.to_s)
        @model.localizations << localization
      end
      localization.value = value
    end

    def set(attribute, value)
      if value.is_a?(Hash)
        value.each do |loc, val|
          set_with_locale(loc, attribute, val)
        end
      else
        set_with_locale(locale, attribute, value)
      end
      value
    end

    def has_value_for?(attribute)
      if localization = get(attribute)
        localization.value?
      else
        false
      end
    end

    def cleanup_localizations!
      @model.localizations = @model.localizations.select{|l| l.value?}
    end
  end

end