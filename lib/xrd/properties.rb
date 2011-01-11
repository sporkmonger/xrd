require 'sax-machine'
require 'addressable/uri'

module XRD
  module Properties
    def self.included(base)
      base.send :include, SAXMachine
      base.send :elements, "Property", :as => :property_values
      base.send :elements, "Property", :as => :property_keys, :value => "type"
      base.send(:elements, "Property",
        :as => :property_nils, :value => "xsi:nil")

      base.send(:remove_method,
        :property_keys, :property_keys=, :add_property_keys
      )
      base.send(:remove_method,
        :property_values, :property_values=, :add_property_values
      )
      base.send(:remove_method,
        :property_nils, :property_nils=, :add_property_nils
      )
    end

    def properties
      return @properties ||= []
    end

  protected
    def add_property_keys(new_property_key)
      @new_property_key = Addressable::URI.parse(new_property_key)
      merge_and_add_property()
      return @new_property_key
    end

    def add_property_values(new_property_value)
      @new_property_value = new_property_value
      merge_and_add_property()
      return @new_property_value
    end

    def add_property_nils(new_property_value)
      # If xsi:nil is set to anything but 'true', ignore it.
      if new_property_value == "true"
        # Hack to detect when we've set this to nil
        @new_property_value = :nil
        merge_and_add_property()
        return @new_property_value
      end
    end

    def merge_and_add_property
      if @new_property_key && @new_property_value
        self.properties << [
          Addressable::URI.parse(@new_property_key),
          @new_property_value == :nil ? nil : @new_property_value
        ]
        @new_property_key, @new_property_value = nil, nil
      end
      return nil
    end
  end
end
