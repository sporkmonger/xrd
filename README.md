# XRD

<dl>
  <dt>Homepage</dt><dd><a href="http://xrd.rubyforge.org/">http://xrd.rubyforge.org/</a></dd>
  <dt>Author</dt><dd><a href="mailto:bobaman@google.com">Bob Aman</a></dd>
  <dt>Copyright</dt><dd>Copyright © 2010 Google, Inc.</dd>
  <dt>License</dt><dd>Apache 2.0</dd>
</dl>

# Description

An XRD parser for Ruby.

# Example Usage

    require 'xrd'
    xrd = XRD.fetch_and_parse(
      'http://www.google.com/s2/webfinger/?q=acct%3Agooglebuzz%40gmail.com'
    )
    xrd.subject
    # => #<Addressable::URI:0x80fb3864 URI:acct:googlebuzz@gmail.com>
    xrd.aliases
    # => [#<Addressable::URI:0x80fb3224 URI:http://www.google.com/profiles/googlebuzz>]
    xrd.links(:media_type => 'application/atom+xml')
    # => [#<XRD::Link:0x80fbc11c URI:https://www.googleapis.com/buzz/v1/activities/111062888259659218284/@public>]
    xrd.links(:rel => 'describedby')
    # => [
    #   #<XRD::Link:0x80fbd224 URI:http://www.google.com/profiles/googlebuzz>,
    #   #<XRD::Link:0x80fbc914 URI:http://www.google.com/s2/webfinger/?q=acct%3Agooglebuzz%40gmail.com&fmt=foaf>
    # ]
    xrd.links(:rel => 'describedby', :media_type => 'text/html')
    # => [#<XRD::Link:0x80fbd224 URI:http://www.google.com/profiles/googlebuzz>]

# Install

* sudo gem install xrd
