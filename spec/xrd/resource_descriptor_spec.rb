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

require 'xrd/resource_descriptor'

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

    it 'should return a parsed URI' do
      @xrd.subject.should be_kind_of(Addressable::URI)
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

    it 'should return parsed URIs' do
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
      (@xrd.properties.map { |k, v| [k.to_str, v.to_str] }).should include(
        ['http://spec.example.net/version', '1.0']
      )
      (@xrd.properties.map { |k, v| [k.to_str, v.to_str] }).should include(
        ['http://spec.example.net/version', '2.0']
      )
    end

    it 'should return parsed URIs' do
      @xrd.properties.each do |k, v|
        k.should be_kind_of(Addressable::URI)
        v.should be_kind_of(String)
      end
    end
  end
end
