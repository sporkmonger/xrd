# Copyright 2010 Google, Inc.
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

require 'xrd/version'
require 'xrd/resource_descriptor'

require 'httpadapter'
require 'httpadapter/adapters/net_http'

module XRD
  def self.parse(xml)
    return XRD::ResourceDescriptor.parse(xml)
  end

  def self.fetch_and_parse(
      uri, adapter=HTTPAdapter::NetHTTPRequestAdapter, connection=nil)
    return XRD::ResourceDescriptor.fetch_and_parse(uri, adapter, connection)
  end
end
