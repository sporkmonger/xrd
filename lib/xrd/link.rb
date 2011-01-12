require 'sax-machine'
require 'addressable/uri'
require 'xrd/properties'
require 'xrd/title'

module XRD
  class Link
    include SAXMachine
    include XRD::Properties

    element "Link", :as => :rel, :value => "rel"
    element "Link", :as => :media_type, :value => "type"
    element "Link", :as => :href, :value => "href"
    elements "Title", :as => :titles, :class => XRD::Title

    def title(lang=nil)
      title = self.titles.detect { |t| t.lang == lang }
      unless title
        title = self.titles.detect { |t| t.lang == nil }
      end
      unless title
        title = self.titles.detect { |t| t.lang == 'en' }
      end
      return title
    end
  end
end
