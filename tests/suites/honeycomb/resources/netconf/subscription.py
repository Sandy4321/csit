# Copyright (c) 2016 Cisco and/or its affiliates.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at:
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""RPC call to add a subscription to Netconf notifications."""

subscription = u"""
<netconf:rpc netconf:message-id="101"
xmlns:netconf="urn:ietf:params:xml:ns:netconf:base:1.0">
<create-subscription
xmlns="urn:ietf:params:xml:ns:netconf:notification:1.0">
<stream>honeycomb</stream>
</create-subscription>
</netconf:rpc>
]]>]]>"""
