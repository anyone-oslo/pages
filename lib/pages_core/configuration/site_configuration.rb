# encoding: utf-8

module PagesCore
  module Configuration
    class SiteConfiguration < PagesCore::Configuration::Handler

      default_handler do |conf, setting, *args|
        if setting.to_s =~ /\?$/
          value = conf.get(setting.to_s.gsub(/\?$/, '').to_sym)
          (value && value != :disabled) ? true : false
        else
          (args && args.length > 0) ? conf.set(setting, *args) : conf.get(setting)
        end
      end

      # Example scope:
      # config.newsletter.template :disabled
      #
      #handle :newsletter do |conf, setting, *args|
      #	if setting.to_s =~ /\?$/
      #		value = conf.get(:newsletter, setting.to_s.gsub(/\?$/, '').to_sym)
      #		(value && value != :disabled) ? true : false
      #	else
      #		(args && args.length > 0) ? conf.set([:newsletter, setting], *args) : conf.get(:newsletter, setting)
      #	end
      #end

      def templates
        PagesCore::Templates.configuration
      end

    end
  end
end
