require 'sax-machine'

module XRD
  class Title < String
    include SAXMachine

    element 'Title', :as => :title
    element 'Title', :as => :lang, :value => 'xml:lang'

    remove_method :title, :title=

  protected
    def title=(new_title)
      # Replace self with new title
      self[0..-1] = new_title
    end
  end
end
