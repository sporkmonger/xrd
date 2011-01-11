require 'time'
require 'sax-machine'
require 'addressable/uri'
require 'httpadapter'
require 'httpadapter/adapters/net_http'
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

    def self.fetch_and_parse(
        uri, adapter=HTTPAdapter::NetHTTPRequestAdapter, connection=nil)
      resource_descriptor = XRD::ResourceDescriptor.new
      resource_descriptor.base_uri = uri
      request = [
        'GET', resource_descriptor.base_uri.to_str,
        [['Accept', 'application/xrd+xml,application/xml;q=0.9,*/*;q=0.9']],
        ['']
      ]
      response = HTTPAdapter.transmit(request, adapter, connection)
      status, headers, body = response
      xrd_content = ""
      body.each do |chunk|
        xrd_content += chunk
      end
      # TODO(sporkmonger) error handling
      return self.parse(xrd_content)
    end

    def base_uri
      return @base_uri ||= nil
    end

    def base_uri=(new_base_uri)
      @base_uri = Addressable::URI.parse(new_base_uri)
    end

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
      return @aliases ||= []
    end

    def add_aliases(new_alias)
      return self.aliases << Addressable::URI.parse(new_alias)
    end
  end
end
