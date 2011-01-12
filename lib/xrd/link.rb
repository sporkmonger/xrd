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
    element "Link", :as => :template, :value => "template"
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

    ##
    # Returns a <code>String</code> representation of the link object's state.
    #
    # @return [String] The Link object's state, as a <code>String</code>.
    def inspect
      if self.template
        sprintf(
          "#<%s:%#0x TEMPLATE:%s>",
          self.class.to_s, self.object_id, self.template
        )
      else
        sprintf(
          "#<%s:%#0x HREF:%s>",
          self.class.to_s, self.object_id, self.href
        )
      end
    end
  end
end
