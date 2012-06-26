module Localizable
  module ActiveRecordExtension
    def localizable(&block)
      unless self.kind_of?(Localizable::ClassMethods)
        self.send :extend,  Localizable::ClassMethods
        self.send :include, Localizable::InstanceMethods
      end
      if block_given?
        localizable_configuration.instance_eval(&block)
      end
    end
  end
end

ActiveRecord::Base.send :extend, Localizable::ActiveRecordExtension