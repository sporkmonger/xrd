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
    remove_method :links

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

    def links(query={})
      @links ||= []
      if query.empty?
        return @links
      else
        result_set = []
        for link in @links
          matched = query.all? do |field, condition|
            case field
            when :rel
              condition === link.rel
            when :media_type, :type
              if link.media_type.kind_of?(String) &&
                  !condition.include?('/')
                link.media_type.to_s.index(condition) == 0
              else
                condition === link.media_type
              end
            when :href, :uri
              if condition.respond_to?(:match)
                condition.match(link.href)
              else
                condition === link.href
              end
            end
          end
          result_set << link if matched
        end
        return result_set
      end
    end

    ##
    # Returns a <code>String</code> representation of the resource descriptor
    # object's state.
    #
    # @return [String]
    #   The resource descriptor object's state, as a <code>String</code>.
    def inspect
      sprintf(
        "#<%s:%#0x SUBJECT:%s>",
        self.class.to_s, self.object_id, self.subject
      )
    end
  end
end
