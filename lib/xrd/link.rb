require 'sax-machine'
require 'addressable/uri'
require 'xrd/properties'

module XRD
  class Link
    include SAXMachine
    include XRD::Properties

    element "Link", :as => :rel, :value => "rel"
    element "Link", :as => :media_type, :value => "type"
    element "Link", :as => :href, :value => "href"
    elements "Title", :as => :titles
  end
end
