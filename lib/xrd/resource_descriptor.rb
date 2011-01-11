require 'time'
require 'sax-machine'
require 'addressable/uri'
require 'xrd/properties'
require 'xrd/link'

module XRD
  NAMESPACE = 'http://docs.oasis-open.org/ns/xri/xrd-1.0'

  class ResourceDescriptor
    include SAXMachine
    include XRD::Properties

    element "XRD", :as => :xml_id, :value => "xml:id"
    element "Expires", :as => :expires
    element "Subject", :as => :subject
    elements "Alias", :as => :aliases
    elements "Link", :as => :links, :class => XRD::Link

    remove_method :expires, :expires=
    remove_method :subject, :subject=
    remove_method :aliases, :add_aliases

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
  end
end
