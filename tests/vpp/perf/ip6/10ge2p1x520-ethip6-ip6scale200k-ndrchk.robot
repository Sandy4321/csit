# Copyright (c) 2017 Cisco and/or its affiliates.
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

*** Settings ***
| Resource | resources/libraries/robot/performance/performance_setup.robot
| ...
| Force Tags | 3_NODE_SINGLE_LINK_TOPO | PERFTEST | HW_ENV | NDRCHK
| ... | NIC_Intel-X520-DA2 | ETH | IP6FWD | SCALE | FIB_200K
| ...
| Suite Setup | Set up 3-node performance topology with DUT's NIC model
| ... | L3 | Intel-X520-DA2
| Suite Teardown | Tear down 3-node performance topology
| ...
| Test Setup | Set up performance test
| Test Teardown | Tear down performance ndrchk test
| ...
| Documentation | *Reference NDR throughput IPv6 routing verify test cases*
| ...
| ... | *[Top] Network Topologies:* TG-DUT1-DUT2-TG 3-node circular topology
| ... | with single links between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv6 for IPv6 routing.
| ... | *[Cfg] DUT configuration:* DUT1 and DUT2 are configured with IPv6
| ... | routing and 2x100k static IPv6 /64 route entries. DUT1 and DUT2 tested
| ... | with 2p10GE NIC X520 Niantic by Intel.
| ... | *[Ver] TG verification:* In short performance tests, TG verifies
| ... | DUTs' throughput at ref-NDR (reference Non Drop Rate) with zero packet
| ... | loss tolerance. Ref-NDR value is periodically updated acording to
| ... | formula: ref-NDR = 0.9x NDR, where NDR is found in RFC2544 long
| ... | performance tests for the same DUT confiiguration. Test packets are
| ... | generated by TG on links to DUTs. TG traffic profile contains two L3
| ... | flow-groups (flow-group per direction, 100k flows per flow-group) with
| ... | all packets containing Ethernet header, IPv6 header and static
| ... | payload. Incrementing of IP.dst (IPv6 destination address) field is
| ... | applied to both streams.
| ... | *[Ref] Applicable standard specifications:* RFC2544.

*** Variables ***
| ${rts_per_flow}= | ${100000}

# Traffic profile:
| ${traffic_profile} | trex-sl-3n-ethip6-ip6dst${rts_per_flow}
*** Test Cases ***
| tc01-78B-1t1c-ethip6-ip6scale200k-ndrchk
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with 1 thread, 1 phy core, \
| | ... | 1 receive queue per NIC port. [Ver] Verify ref-NDR for 78 Byte
| | ... | frames using single trial throughput test at 2x 2.3mpps.
| | [Tags] | 78B | 1T1C | STHREAD
| | ${framesize}= | Set Variable | ${78}
| | ${rate}= | Set Variable | 2.3mpps
| | Given Add '1' worker threads and '1' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to DUTs in 3-node single link topology
| | And Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv6 forwarding with scaling in 3-node circular topology
| | ... | ${rts_per_flow}
| | Then Traffic should pass with no loss | ${perf_trial_duration} | ${rate}
| | ... | ${framesize} | ${traffic_profile}

| tc02-1518B-1t1c-ethip6-ip6scale200k-ndrchk
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with 1 thread, 1 phy core, \
| | ... | 1 receive queue per NIC port. [Ver] Verify ref-NDR for 1518 Byte
| | ... | frames using single trial throughput test at 2x 812743pps.
| | [Tags] | 1518B | 1T1C | STHREAD
| | ${framesize}= | Set Variable | ${1518}
| | ${rate}= | Set Variable | 812743pps
| | Given Add '1' worker threads and '1' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to DUTs in 3-node single link topology
| | And Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv6 forwarding with scaling in 3-node circular topology
| | ... | ${rts_per_flow}
| | Then Traffic should pass with no loss | ${perf_trial_duration} | ${rate}
| | ... | ${framesize} | ${traffic_profile}

| tc03-9000B-1t1c-ethip6-ip6scale200k-ndrchk
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with 1 thread, 1 phy core, \
| | ... | 1 receive queue per NIC port. [Ver] Verify ref-NDR for 9000 Byte
| | ... | frames using single trial throughput test at 2x 138580pps.
| | [Tags] | 9000B | 1T1C | STHREAD
| | ${framesize}= | Set Variable | ${9000}
| | ${rate}= | Set Variable | 138580pps
| | Given Add '1' worker threads and '1' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to DUTs in 3-node single link topology
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv6 forwarding with scaling in 3-node circular topology
| | ... | ${rts_per_flow}
| | Then Traffic should pass with no loss | ${perf_trial_duration} | ${rate}
| | ... | ${framesize} | ${traffic_profile}

| tc04-78B-2t2c-ethip6-ip6scale200k-ndrchk
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with 2 threads, 2 phy cores, \
| | ... | 1 receive queue per NIC port. [Ver] Verify ref-NDR for 78 Byte
| | ... | frames using single trial throughput test at 2x 4.4mpps.
| | [Tags] | 78B | 2T2C | MTHREAD
| | ${framesize}= | Set Variable | ${78}
| | ${rate}= | Set Variable | 4.4mpps
| | Given Add '2' worker threads and '1' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to DUTs in 3-node single link topology
| | And Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv6 forwarding with scaling in 3-node circular topology
| | ... | ${rts_per_flow}
| | Then Traffic should pass with no loss | ${perf_trial_duration} | ${rate}
| | ... | ${framesize} | ${traffic_profile}

| tc05-1518B-2t2c-ethip6-ip6scale200k-ndrchk
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with 2 threads, 2 phy cores, \
| | ... | 1 receive queue per NIC port. [Ver] Verify ref-NDR for 1518 Byte
| | ... | frames using single trial throughput test at 2x 812743pps.
| | [Tags] | 1518B | 2T2C | MTHREAD
| | ${framesize}= | Set Variable | ${1518}
| | ${rate}= | Set Variable | 812743pps
| | Given Add '2' worker threads and '1' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to DUTs in 3-node single link topology
| | And Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv6 forwarding with scaling in 3-node circular topology
| | ... | ${rts_per_flow}
| | Then Traffic should pass with no loss | ${perf_trial_duration} | ${rate}
| | ... | ${framesize} | ${traffic_profile}

| tc06-9000B-2t2c-ethip6-ip6scale200k-ndrchk
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with 2 threads, 2 phy cores, \
| | ... | 1 receive queue per NIC port. [Ver] Verify ref-NDR for 9000 Byte
| | ... | frames using single trial throughput test at 2x 138580pps.
| | [Tags] | 9000B | 2T2C | MTHREAD
| | ${framesize}= | Set Variable | ${9000}
| | ${rate}= | Set Variable | 138580pps
| | Given Add '2' worker threads and '1' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to DUTs in 3-node single link topology
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv6 forwarding with scaling in 3-node circular topology
| | ... | ${rts_per_flow}
| | Then Traffic should pass with no loss | ${perf_trial_duration} | ${rate}
| | ... | ${framesize} | ${traffic_profile}

| tc07-78B-4t4c-ethip6-ip6scale200k-ndrchk
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with 4 threads, 4 phy cores, \
| | ... | 2 receive queue per NIC port. [Ver] Verify ref-NDR for 78 Byte
| | ... | frames using single trial throughput test at 2x 5.7mpps.
| | [Tags] | 78B | 4T4C | MTHREAD
| | ${framesize}= | Set Variable | ${78}
| | ${rate}= | Set Variable | 5.7mpps
| | Given Add '4' worker threads and '2' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to DUTs in 3-node single link topology
| | And Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv6 forwarding with scaling in 3-node circular topology
| | ... | ${rts_per_flow}
| | Then Traffic should pass with no loss | ${perf_trial_duration} | ${rate}
| | ... | ${framesize} | ${traffic_profile}

| tc08-1518B-4t4c-ethip6-ip6scale200k-ndrchk
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with 4 threads, 4 phy cores, \
| | ... | 2 receive queue per NIC port. [Ver] Verify ref-NDR for 1518 Byte
| | ... | frames using single trial throughput test at 2x 812743pps.
| | [Tags] | 1518B | 4T4C | MTHREAD
| | ${framesize}= | Set Variable | ${1518}
| | ${rate}= | Set Variable | 812743pps
| | Given Add '4' worker threads and '2' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to DUTs in 3-node single link topology
| | And Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv6 forwarding with scaling in 3-node circular topology
| | ... | ${rts_per_flow}
| | Then Traffic should pass with no loss | ${perf_trial_duration} | ${rate}
| | ... | ${framesize} | ${traffic_profile}

| tc09-9000B-4t4c-ethip6-ip6scale200k-ndrchk
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with 4 threads, 4 phy cores, \
| | ... | 2 receive queue per NIC port. [Ver] Verify ref-NDR for 9000 Byte
| | ... | frames using single trial throughput test at 2x 138580pps.
| | [Tags] | 9000B | 4T4C | MTHREAD
| | ${framesize}= | Set Variable | ${9000}
| | ${rate}= | Set Variable | 138580pps
| | Given Add '4' worker threads and '2' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to DUTs in 3-node single link topology
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv6 forwarding with scaling in 3-node circular topology
| | ... | ${rts_per_flow}
| | Then Traffic should pass with no loss | ${perf_trial_duration} | ${rate}
| | ... | ${framesize} | ${traffic_profile}
