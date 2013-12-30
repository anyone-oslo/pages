# encoding: utf-8

module PagesCore::Deprecations
  module DeprecatedHelper

    def hash_for_translated_route(options, target_locale)
      ActiveSupport::Deprecation.warn "hash_for_translated_route is deprecated"
      if is_page_route?(options)
        if options[:id].kind_of?(Page)
          page = options[:id]
        elsif options[:id]
          page = Page.find(options[:id]) rescue nil
        elsif @page
          page = @page
        end
        if page
          options = options.merge(:id => page.localize(target_locale).to_param, :action => 'show')
        end
      end
      options = options.merge({locale: target_locale})
    end

    def indent(string, level=0)
      ActiveSupport::Deprecation.warn "indent is deprecated, use String#indent"
      string.indent((level * 2), " ")
    end

    # Generate HTML for a field, with label and optionally description and errors.
    #
    # The options are:
    # * <tt>:description</tt>: Description of the field
    # * <tt>:errors</tt>:      Error messages for the attribute
    #
    # An example:
    #   <%= form_for @user do |f| %>
    #     <%= labelled_field f.text_field(:username), "Username",
    #                        :description => "Choose your username, minimum 4 characters",
    #                        :errors => @user.errors[:username] %>
    #     <%= submit_tag "Save" %>
    #   <% end %>
    #
    def labelled_field(field, label=nil, options={})
      ActiveSupport::Deprecation.warn "labelled_field is deprecated, use PagesCore::FormBuilder"
      options = {
        :field_tag => 'p'
      }.merge(options)
      if options[:errors] && options[:errors].any?
        output  = "<#{options[:field_tag]} class=\"field field_with_errors\">"
      else
        output  = "<#{options[:field_tag]} class=\"field\">"
      end
      output += "<label>#{label}" if label
      if options[:errors] && options[:errors].any?
        error = options[:errors]
        error = error.last if error.kind_of? Array
        output += ' <span class="error">' + error.to_s[] + '</span>'
      end
      output += "</label>" if label
      output += options[:description] + "<br />" if options[:description]
      output += field
      output += "</#{options[:field_tag]}>"
    end

    def smart_time(time, options={})
      ActiveSupport::Deprecation.warn "smart_time is deprecated, use the Rails I18N API"
      options.symbolize_keys!
      options[:include_distance] ||= false
      options[:always_include_time] ||= false

      if options[:skip_prefix]
        date_string = ""
      else
        date_string = (time.to_date == Time.now.to_date) ? "at " : "on "
      end

      if time.to_date == Time.now.to_date
        date_string += time.strftime("%H:%M")
      elsif time.year == Time.now.year
        date_string += time.strftime("%b %d")
        date_string += time.strftime(" at %H:%M") if options[:always_include_time]
      else
        date_string += time.strftime("%b %d %Y")
        date_string += time.strftime(" at %H:%M") if options[:always_include_time]
        options[:include_distance] = false
      end

      date_string += " (" + time_ago_in_words( time ) + " ago)" if options[:include_distance]

      date_string
    end

    protected

    def is_page_route?(options={})
      (options[:controller] == 'pages' && options[:action] =~ /^(index|show)$/) ? true : false
    end
  end
end