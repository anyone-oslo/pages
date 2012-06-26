module ActiveRecord
  class Base
  end
end

require File.join(File.dirname(__FILE__), 'localizable', 'active_record_extension')
require File.join(File.dirname(__FILE__), 'localizable', 'class_methods')
require File.join(File.dirname(__FILE__), 'localizable', 'configuration')
require File.join(File.dirname(__FILE__), 'localizable', 'instance_methods')
require File.join(File.dirname(__FILE__), 'localizable', 'localizer')

module Localizable
end


class Page < ActiveRecord::Base
  #acts_as_textable :name, :body, :excerpt, :headline, :boxout, :allow_any => true
  localizable do
    attribute :name
    attribute :body
    attribute :excerpt
    attribute :headline
    attribute :boxout
    allow_any true
  end
end

puts Page.new.localizer.configuration.allow_any?.inspect