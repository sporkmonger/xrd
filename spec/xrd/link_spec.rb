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

require 'xrd/link'

describe XRD::Link do
  describe 'when attempting to parse an XRD document' do
    describe 'with a Link element containing an auth link' do
      before do
        @xml = <<-XML
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
  <Link rel="http://spec.example.net/auth/1.0"
        href="http://services.example.com/auth" />
</XRD>
        XML
        @xrd = XRD::ResourceDescriptor.parse(@xml)
      end

      it 'should return the correct rel value' do
        @xrd.links.first.rel.should == 'http://spec.example.net/auth/1.0'
      end

      it 'should return the correct href value' do
        @xrd.links.first.href.should == 'http://services.example.com/auth'
      end
    end

    describe 'with a Link element containing an image link' do
      before do
        @xml = <<-XML
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
  <Link rel="http://spec.example.net/photo/1.0" type="image/jpeg"
        href="http://photos.example.com/gpburdell.jpg">
</XRD>
        XML
        @xrd = XRD::ResourceDescriptor.parse(@xml)
      end

      it 'should return the correct rel value' do
        @xrd.links.first.rel.should == 'http://spec.example.net/photo/1.0'
      end

      it 'should return the correct media type value' do
        @xrd.links.first.media_type.should == 'image/jpeg'
      end

      it 'should return the correct href value' do
        @xrd.links.first.href.should ==
          'http://photos.example.com/gpburdell.jpg'
      end
    end
  end
end
