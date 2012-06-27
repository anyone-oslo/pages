module Localizable
  module ActiveRecordExtension
    def localizable(&block)
      unless self.kind_of?(Localizable::ClassMethods)
        self.send :extend,  Localizable::ClassMethods
        self.send :include, Localizable::InstanceMethods
        has_many :localizations, :as => :localizable, :dependent => :destroy, :autosave => true
        before_save :cleanup_localizations!
      end
      if block_given?
        localizable_configuration.instance_eval(&block)
      end
    end
  end
end

ActiveRecord::Base.send :extend, Localizable::ActiveRecordExtension