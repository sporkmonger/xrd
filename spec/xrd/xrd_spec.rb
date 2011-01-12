# Copyright (C) 2010 Google Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

require 'spec_helper'

require 'httpadapter/adapters/mock'
require 'addressable/uri'
require 'addressable/template'

require 'xrd'

describe XRD::ResourceDescriptor do
  describe 'with an initialized resource descriptor' do
    before do
      @xrd = XRD::ResourceDescriptor.new
    end

    it 'should allow expiration dates to be set to Time objects' do
      now = Time.now
      @xrd.expires = now
      @xrd.expires.should == now
    end

    it 'should allow expiration dates to be set to String objects' do
      now = Time.now
      @xrd.expires = now.to_s
      @xrd.expires.to_s.should == now.to_s
    end

    it 'should allow subject values to be set to URI objects' do
      @xrd.subject = Addressable::URI.parse('http://example.com/subject')
      @xrd.subject.should == Addressable::URI.parse(
        'http://example.com/subject'
      )
    end

    it 'should allow subject values to be set to String objects' do
      @xrd.subject = 'http://example.com/subject'
      @xrd.subject.should == Addressable::URI.parse(
        'http://example.com/subject'
      )
    end

    it 'should not allow direct access to the property_keys' do
      (lambda do
        @xrd.property_keys
      end).should raise_error(NoMethodError)
      (lambda do
        @xrd.property_keys = []
      end).should raise_error(NoMethodError)
    end

    it 'should not allow direct access to the property_values' do
      (lambda do
        @xrd.property_values
      end).should raise_error(NoMethodError)
      (lambda do
        @xrd.property_values = []
      end).should raise_error(NoMethodError)
    end

    it 'should be inspectable' do
      @xrd.inspect.should be_kind_of(String)
    end
  end

  describe 'when attempting to parse an empty XRD document' do
    before do
      @xml = <<-XML
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
</XRD>
      XML
      @xrd = XRD::ResourceDescriptor.parse(@xml)
    end

    it 'should return a blank resource descriptor' do
      @xrd.xml_id.should == nil
      @xrd.expires.should == nil
      @xrd.subject.should == nil
      @xrd.aliases.should == []
      @xrd.properties.should == []
      @xrd.links.should == []
    end
  end

  describe 'when attempting to parse an XRD document with an id' do
    before do
      @xml = <<-XML
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0" xml:id="identifier">
</XRD>
      XML
      @xrd = XRD::ResourceDescriptor.parse(@xml)
    end

    it 'should return the correct id' do
      @xrd.xml_id.should == "identifier"
    end
  end

  describe 'when attempting to parse an XRD document with an Expires value' do
    before do
      @xml = <<-XML
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
  <Expires>1970-01-01T00:00:00Z</Expires>
</XRD>
      XML
      @xrd = XRD::ResourceDescriptor.parse(@xml)
    end

    it 'should return the correct expiration date' do
      @xrd.expires.should == Time.gm(1970)
    end
  end

  describe 'when attempting to parse an XRD document with a Subject value' do
    before do
      @xml = <<-XML
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
  <Subject>http://example.com/subject</Expires>
</XRD>
      XML
      @xrd = XRD::ResourceDescriptor.parse(@xml)
    end

    it 'should return the correct subject' do
      @xrd.subject.to_str.should == 'http://example.com/subject'
    end

    it 'should return a parsed subject URI' do
      @xrd.subject.should be_kind_of(Addressable::URI)
    end

    it 'should be inspectable' do
      @xrd.inspect.should be_kind_of(String)
      @xrd.inspect.should include('http://example.com/subject')
    end
  end

  describe 'when attempting to parse an XRD document with Alias values' do
    before do
      @xml = <<-XML
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
  <Alias>http://people.example.com/subject</Alias>
  <Alias>acct:subject@example.com</Alias>
</XRD>
      XML
      @xrd = XRD::ResourceDescriptor.parse(@xml)
    end

    it 'should return the correct aliases' do
      (@xrd.aliases.map { |a| a.to_str }).should include(
        'http://people.example.com/subject'
      )
      (@xrd.aliases.map { |a| a.to_str }).should include(
        'acct:subject@example.com'
      )
    end

    it 'should return parsed alias URIs' do
      @xrd.aliases.each do |a|
        a.should be_kind_of(Addressable::URI)
      end
    end
  end

  describe 'when attempting to parse an XRD document with Property values' do
    before do
      @xml = <<-XML
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
  <Property type="http://spec.example.net/version">1.0</Property>
  <Property type="http://spec.example.net/version">2.0</Property>
</XRD>
      XML
      @xrd = XRD::ResourceDescriptor.parse(@xml)
    end

    it 'should return the correct properties' do
      (@xrd.properties.map { |k, v| [k.to_str, v] }).should include(
        ['http://spec.example.net/version', '1.0']
      )
      (@xrd.properties.map { |k, v| [k.to_str, v] }).should include(
        ['http://spec.example.net/version', '2.0']
      )
    end

    it 'should return parsed property key URIs' do
      @xrd.properties.each do |k, v|
        k.should be_kind_of(Addressable::URI)
        v.should be_kind_of(String)
      end
    end
  end

  shared_examples_for 'simple XRD example' do
    it 'should return the correct expiration date' do
      @xrd.expires.should == Time.gm(1970)
    end

    it 'should return the correct subject' do
      @xrd.subject.to_str.should == 'http://example.com/subject'
    end

    it 'should return a parsed subject URI' do
      @xrd.subject.should be_kind_of(Addressable::URI)
    end

    it 'should return the correct properties' do
      (@xrd.properties.map { |k, v| [k.to_str, v] }).should include(
        ['http://spec.example.net/type/person', nil]
      )
    end

    it 'should return parsed property key URIs' do
      @xrd.properties.each do |k, v|
        k.should be_kind_of(Addressable::URI)
        v.should be_kind_of(NilClass)
      end
    end

    it 'should return the correct links' do
      @xrd.links[0].rel.should == 'http://spec.example.net/auth/1.0'
      @xrd.links[0].href.should == 'http://services.example.com/auth'
      @xrd.links[1].rel.should == 'http://spec.example.net/photo/1.0'
      @xrd.links[1].media_type.should == 'image/jpeg'
      @xrd.links[1].href.should == 'http://photos.example.com/gpburdell.jpg'
    end

    it 'should return the correct link titles' do
      @xrd.links[1].title.should == 'User Photo'
      @xrd.links[1].title('en').should == 'User Photo'
      @xrd.links[1].title('de').should == 'Benutzerfoto'

      @xrd.links[1].title.lang.should == 'en'
      @xrd.links[1].title('en').lang.should == 'en'
      @xrd.links[1].title('de').lang.should == 'de'
    end

    it 'should return the correct link properties' do
      @xrd.links[1].properties[0][0].should ===
        'http://spec.example.net/created/1.0'
      @xrd.links[1].properties[0][1].should == '1970-01-01'
    end

    it 'should allow links to be queried by rel value' do
      links = @xrd.links(:rel => 'http://spec.example.net/auth/1.0')
      links.length.should == 1
      links[0].rel.should == 'http://spec.example.net/auth/1.0'
    end

    it 'should allow links to be queried by rel value' do
      links = @xrd.links(:rel => 'alternate')
      links.length.should == 0
    end

    it 'should allow links to be queried by media type' do
      links = @xrd.links(:media_type => 'image/jpeg')
      links.length.should == 1
      links[0].media_type.should == 'image/jpeg'
    end

    it 'should allow links to be queried by media type' do
      links = @xrd.links(:media_type => 'text/html')
      links.length.should == 0
    end

    it 'should allow links to be queried by media type' do
      links = @xrd.links(:media_type => 'image')
      links.length.should == 1
      links[0].media_type.should == 'image/jpeg'
    end

    it 'should allow links to be queried by media type' do
      links = @xrd.links(:media_type => 'text')
      links.length.should == 0
    end

    it 'should allow links to be queried by href' do
      links = @xrd.links(:href => 'http://services.example.com/auth')
      links.length.should == 1
      links[0].href.should == 'http://services.example.com/auth'
    end

    it 'should allow links to be queried by href' do
      links = @xrd.links(:href => 'http://www.example.org/')
      links.length.should == 0
    end

    it 'should allow links to be queried by href' do
      links = @xrd.links(
        :href => Addressable::URI.parse('http://services.example.com/auth')
      )
      links.length.should == 1
      links[0].href.should == 'http://services.example.com/auth'
    end

    it 'should allow links to be queried by href' do
      links = @xrd.links(
        :href => Addressable::URI.parse('http://www.example.org/')
      )
      links.length.should == 0
    end

    it 'should allow links to be queried by href' do
      links = @xrd.links(:href => /services\.example\.com/)
      links.length.should == 1
      links[0].href.should == 'http://services.example.com/auth'
    end

    it 'should allow links to be queried by href' do
      links = @xrd.links(:href => /www\.example\.org/)
      links.length.should == 0
    end

    it 'should allow links to be queried by href' do
      links = @xrd.links(
        :href => Addressable::Template.new('http://{sub}.example.com/{path}')
      )
      links.length.should == 2
      links[0].href.should == 'http://services.example.com/auth'
      links[1].href.should == 'http://photos.example.com/gpburdell.jpg'
    end

    it 'should allow links to be queried by href' do
      links = @xrd.links(
        :href => Addressable::Template.new('http://www.example.org/{path}')
      )
      links.length.should == 0
    end
  end

  describe 'when attempting to fetch and parse an XRD document' do
    before do
      @xml = <<-XML
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <Expires>1970-01-01T00:00:00Z</Expires>
  <Subject>http://example.com/subject</Subject>
  <Property type="http://spec.example.net/type/person" xsi:nil="true" />
  <Link rel="http://spec.example.net/auth/1.0"
    href="http://services.example.com/auth" />
  <Link rel="http://spec.example.net/photo/1.0" type="image/jpeg"
    href="http://photos.example.com/gpburdell.jpg">
    <Title xml:lang="en">User Photo</Title>
    <Title xml:lang="de">Benutzerfoto</Title>
    <Property type="http://spec.example.net/created/1.0">1970-01-01</Property>
  </Link>
</XRD>
      XML
      @adapter = HTTPAdapter::MockAdapter.request_adapter do |request, conn|
        [
          200,
          [['Content-Type', 'application/xrd+xml']],
          [@xml],
        ]
      end
      @xrd = XRD::ResourceDescriptor.fetch_and_parse(
        'http://example.com/xrd', @adapter
      )
    end

    it_should_behave_like 'simple XRD example'
  end

  describe 'when attempting to fetch and parse an XRD document' do
    before do
      @xml = <<-XML
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <Expires>1970-01-01T00:00:00Z</Expires>
  <Subject>http://example.com/subject</Subject>
  <Property type="http://spec.example.net/type/person" xsi:nil="true" />
  <Link rel="http://spec.example.net/auth/1.0"
    href="http://services.example.com/auth" />
  <Link rel="http://spec.example.net/photo/1.0" type="image/jpeg"
    href="http://photos.example.com/gpburdell.jpg">
    <Title xml:lang="en">User Photo</Title>
    <Title xml:lang="de">Benutzerfoto</Title>
    <Property type="http://spec.example.net/created/1.0">1970-01-01</Property>
  </Link>
</XRD>
      XML
      @adapter = HTTPAdapter::MockAdapter.request_adapter do |request, conn|
        [
          200,
          [['Content-Type', 'application/xrd+xml']],
          [@xml],
        ]
      end
      @xrd = XRD.fetch_and_parse('http://example.com/xrd', @adapter)
    end

    it_should_behave_like 'simple XRD example'
  end

  describe 'when attempting to parse an XRD document with no title lang' do
    before do
      @xml = <<-XML
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <Link rel="http://spec.example.net/photo/1.0" type="image/jpeg"
    href="http://photos.example.com/gpburdell.jpg">
    <Title>User Photo</Title>
    <Title xml:lang="de">Benutzerfoto</Title>
  </Link>
</XRD>
      XML
      @xrd = XRD.parse(@xml)
    end

    it 'should return the correct link titles' do
      @xrd.links[0].title.should == 'User Photo'
      @xrd.links[0].title('en').should == 'User Photo'
      @xrd.links[0].title('de').should == 'Benutzerfoto'

      @xrd.links[0].title.lang.should == nil
      @xrd.links[0].title('en').lang.should == nil
      @xrd.links[0].title('de').lang.should == 'de'
    end
  end
end
