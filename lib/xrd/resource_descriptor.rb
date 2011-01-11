require 'sax-machine'
require 'time'
require 'addressable/uri'

module XRD
  NAMESPACE = 'http://docs.oasis-open.org/ns/xri/xrd-1.0'

  class ResourceDescriptor
    include SAXMachine

    element "XRD", :as => :xml_id, :value => "xml:id"
    element "Expires", :as => :expires
    element "Subject", :as => :subject
    elements "Alias", :as => :aliases
    elements "Property", :as => :property_values
    elements "Property", :as => :property_keys, :value => "type"
    elements "Link", :as => :links

    attr_reader :expires

    def expires=(new_expires)
      if new_expires.kind_of?(Time)
        @expires = new_expires
      else
        @expires = Time.parse(new_expires.to_s)
      end
    end

    attr_reader :subject

    def subject=(new_subject)
      @subject = Addressable::URI.parse(new_subject)
    end

    def aliases
      @aliases ||= []
    end

    def add_aliases(new_alias)
      self.aliases << Addressable::URI.parse(new_alias)
    end

    def properties
      @properties ||= []
    end

  protected
    def add_property_keys(new_property_key)
      @new_property_key = new_property_key
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

    begin
      remove_method :property_keys, :property_keys=
      remove_method :property_values, :property_values=
    rescue Exception
      # It's OK if this fails.  Nobody wants to know about it.
    end
  end
end
