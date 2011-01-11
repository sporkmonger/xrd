require 'sax-machine'
require 'addressable/uri'

module XRD
  module Properties
    def self.included(base)
      base.send :include, SAXMachine
      base.send :elements, "Property", :as => :property_values
      base.send :elements, "Property", :as => :property_keys, :value => "type"

      base.send :remove_method, :add_property_keys
      base.send :remove_method, :add_property_values
      base.send :remove_method, :property_keys, :property_keys=
      base.send :remove_method, :property_values, :property_values=
    end

    def properties
      @properties ||= []
    end

  protected
    def add_property_keys(new_property_key)
      @new_property_key = Addressable::URI.parse(new_property_key)
      merge_and_add_property()
    end

    def add_property_values(new_property_value)
      @new_property_value = new_property_value
      merge_and_add_property()
    end

    def merge_and_add_property
      if @new_property_key && @new_property_value
        self.properties << [
          Addressable::URI.parse(@new_property_key),
          @new_property_value
        ]
        @new_property_key, @new_property_value = nil, nil
      end
    end
  end
end
