# Copyright (c) 2018 Cisco and/or its affiliates.
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
| Library | resources.libraries.python.QemuUtils
| ...
| Force Tags | 3_NODE_SINGLE_LINK_TOPO | PERFTEST | HW_ENV | MRR
| ... | NIC_Intel-X710 | ETH | IP4FWD | BASE | VHOST | 1VM | VHOST_1024
| ...
| Suite Setup | Set up 3-node performance topology with DUT's NIC model
| ... | L3 | Intel-X710
| Suite Teardown | Tear down 3-node performance topology
| ...
| Test Setup | Set up performance test
| Test Teardown | Tear down performance mrr test with vhost and VM with dpdk-testpmd
| ... | dut1_node=${dut1} | dut1_vm_refs=${dut1_vm_refs}
| ... | dut2_node=${dut2} | dut2_vm_refs=${dut2_vm_refs}
| ...
| Documentation | *Raw results IPv4 test cases with vhost*
| ...
| ... | *[Top] Network Topologies:* TG-DUT1-DUT2-TG 3-node circular topology
| ... | with single links between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv4 for IPv4 routing.
| ... | *[Cfg] DUT configuration:* DUT1 and DUT2 are configured with IPv4
| ... | routing and two static IPv4 /24 route entries. Qemu Guest is connected
| ... | to VPP via vhost-user interfaces. Guest is running DPDK testpmd
| ... | interconnecting vhost-user interfaces using 5 cores pinned to cpus 5-9
| ... | and 2048M memory. Testpmd is using socket-mem=1024M (512x2M hugepages),
| ... | 5 cores (1 main core and 4 cores dedicated for io), forwarding mode is
| ... | set to mac, rxd/txd=1024, burst=64. DUT1, DUT2 are tested with 2p10GE
| ... | NIC X710 by Intel.
| ... | *[Ver] TG verification:* In MaxReceivedRate test TG sends traffic
| ... | at line rate and reports total received/sent packets over trial period.
| ... | Test packets are generated by TG on links to DUTs. TG traffic profile
| ... | contains two L3 flow-groups (flow-group per direction, 253 flows per
| ... | flow-group) with all packets containing Ethernet header, IPv4 header
| ... | with IP protocol=61 and static payload. MAC addresses are matching MAC
| ... | addresses of the TG node interfaces.

*** Variables ***
| ${perf_qemu_qsz}= | 1024
# Socket names
| ${sock1}= | /tmp/sock-1
| ${sock2}= | /tmp/sock-2
# FIB tables
| ${fib_table_1}= | 100
| ${fib_table_2}= | 101
# X710 bandwidth limit
| ${s_limit}= | ${10000000000}
# Traffic profile:
| ${traffic_profile} | trex-sl-3n-ethip4-ip4src253

*** Keywords ***
| Check RR for ethip4-ip4base-eth-2vhostvr1024-1vm
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing config with ${wt} thread, ${wt} phy\
| | ... | core, ${rxq} receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for ${framesize} frames using single\
| | ... | trial throughput test.
| | ...
| | [Arguments] | ${framesize} | ${wt} | ${rxq}
| | ...
| | # Test Variables required for test and test teardown
| | Set Test Variable | ${framesize}
| | ${get_framesize}= | Get Frame Size | ${framesize}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${dut1_vm_refs}= | Create Dictionary
| | ${dut2_vm_refs}= | Create Dictionary
| | Set Test Variable | ${dut1_vm_refs}
| | Set Test Variable | ${dut2_vm_refs}
| | ${jumbo_frames}= | Set Variable If | ${get_framesize} < ${1522}
| | ... | ${False} | ${True}
| | ...
| | Given Add '${wt}' worker threads and '${rxq}' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to DUTs in 3-node single link topology
| | And Run Keyword If | ${get_framesize} < ${1522}
| | ... | Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | When Initialize IPv4 forwarding with vhost in 3-node circular topology
| | ... | ${sock1} | ${sock2}
| | ${vm1}= | And Configure guest VM with dpdk-testpmd-mac connected via vhost-user
| | ... | ${dut1} | ${sock1} | ${sock2} | DUT1_VM1 | ${dut1_vif1_mac}
| | ... | ${dut1_vif2_mac} | jumbo_frames=${jumbo_frames}
| | Set To Dictionary | ${dut1_vm_refs} | DUT1_VM1 | ${vm1}
| | ${vm2}= | And Configure guest VM with dpdk-testpmd-mac connected via vhost-user
| | ... | ${dut2} | ${sock1} | ${sock2} | DUT2_VM1 | ${dut2_vif1_mac}
| | ... | ${dut2_vif2_mac} | jumbo_frames=${jumbo_frames}
| | Set To Dictionary | ${dut2_vm_refs} | DUT2_VM1 | ${vm2}
| | Then Traffic should pass with maximum rate | ${perf_trial_duration}
| | ... | ${max_rate}pps | ${framesize} | ${traffic_profile}

*** Test Cases ***
| tc01-64B-1t1c-ethip4-ip4base-eth-2vhostvr1024-1vm-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing config with 1 thread, 1 phy\
| | ... | core, 1 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 64B frames using single\
| | ... | trial throughput test.
| | ...
| | [Tags] | 64B | 1T1C | STHREAD
| | ...
| | [Template] | Check RR for ethip4-ip4base-eth-2vhostvr1024-1vm
| | framesize=${64} | wt=1 | rxq=1

| tc02-1518B-1t1c-ethip4-ip4base-eth-2vhostvr1024-1vm-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing config with 1 thread, 1 phy\
| | ... | core, 1 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 1518B frames using single\
| | ... | trial throughput test.
| | ...
| | [Tags] | 1518B | 1T1C | STHREAD
| | ...
| | [Template] | Check RR for ethip4-ip4base-eth-2vhostvr1024-1vm
| | framesize=${1518} | wt=1 | rxq=1

| tc03-9000B-1t1c-ethip4-ip4base-eth-2vhostvr1024-1vm-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing config with 1 thread, 1 phy\
| | ... | core, 1 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 9000B frames using single\
| | ... | trial throughput test.
| | ...
| | [Tags] | 9000B | 1T1C | STHREAD
| | ...
| | [Template] | Check RR for ethip4-ip4base-eth-2vhostvr1024-1vm
| | framesize=${9000} | wt=1 | rxq=1

| tc04-IMIX-1t1c-ethip4-ip4base-eth-2vhostvr1024-1vm-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing config with 1 thread, 1 phy\
| | ... | core, 1 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for IMIX_v4_1 frames using single\
| | ... | trial throughput test.
| | ... | IMIX_v4_1 = (28x64B; 16x570B; 4x1518B)
| | ...
| | [Tags] | IMIX | 1T1C | STHREAD
| | ...
| | [Template] | Check RR for ethip4-ip4base-eth-2vhostvr1024-1vm
| | framesize=IMIX_v4_1 | wt=1 | rxq=1

| tc05-64B-2t2c-ethip4-ip4base-eth-2vhostvr1024-1vm-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing config with 2 threads, 2 phy\
| | ... | cores, 1 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 64B frames using single\
| | ... | trial throughput test.
| | ...
| | [Tags] | 64B | 2T2C | MTHREAD
| | ...
| | [Template] | Check RR for ethip4-ip4base-eth-2vhostvr1024-1vm
| | framesize=${64} | wt=2 | rxq=1

| tc06-1518B-2t2c-ethip4-ip4base-eth-2vhostvr1024-1vm-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing config with 2 threads, 2 phy\
| | ... | cores, 1 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 1518B frames using single\
| | ... | trial throughput test.
| | ...
| | [Tags] | 1518B | 2T2C | MTHREAD
| | ...
| | [Template] | Check RR for ethip4-ip4base-eth-2vhostvr1024-1vm
| | framesize=${1518} | wt=2 | rxq=1

| tc07-9000B-2t2c-ethip4-ip4base-eth-2vhostvr1024-1vm-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing config with 2 threads, 2 phy\
| | ... | cores, 1 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 9000B frames using single\
| | ... | trial throughput test.
| | ...
| | [Tags] | 9000B | 2T2C | MTHREAD
| | ...
| | [Template] | Check RR for ethip4-ip4base-eth-2vhostvr1024-1vm
| | framesize=${9000} | wt=2 | rxq=1

| tc08-IMIX-2t2c-ethip4-ip4base-eth-2vhostvr1024-1vm-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing config with 2 threads, 2 phy\
| | ... | cores, 1 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for IMIX_v4_1 frames using single\
| | ... | trial throughput test.
| | ... | IMIX_v4_1 = (28x64B; 16x570B; 4x1518B)
| | ...
| | [Tags] | IMIX | 2T2C | MTHREAD
| | ...
| | [Template] | Check RR for ethip4-ip4base-eth-2vhostvr1024-1vm
| | framesize=IMIX_v4_1 | wt=2 | rxq=1

| tc09-64B-4t4c-ethip4-ip4base-eth-2vhostvr1024-1vm-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing config with 4 threads, 4 phy\
| | ... | cores, 2 receive queues per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 64B frames using single\
| | ... | trial throughput test.
| | ...
| | [Tags] | 64B | 4T4C | MTHREAD
| | ...
| | [Template] | Check RR for ethip4-ip4base-eth-2vhostvr1024-1vm
| | framesize=${64} | wt=4 | rxq=2

| tc10-1518B-4t4c-ethip4-ip4base-eth-2vhostvr1024-1vm-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing config with 4 threads, 4 phy\
| | ... | cores, 2 receive queues per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 1518B frames using single\
| | ... | trial throughput test.
| | ...
| | [Tags] | 1518B | 4T4C | MTHREAD
| | ...
| | [Template] | Check RR for ethip4-ip4base-eth-2vhostvr1024-1vm
| | framesize=${1518} | wt=4 | rxq=2

| tc11-9000B-4t4c-ethip4-ip4base-eth-2vhostvr1024-1vm-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing config with 4 threads, 4 phy\
| | ... | cores, 2 receive queues per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 9000B frames using single\
| | ... | trial throughput test.
| | ...
| | [Tags] | 9000B | 4T4C | MTHREAD
| | ...
| | [Template] | Check RR for ethip4-ip4base-eth-2vhostvr1024-1vm
| | framesize=${9000} | wt=4 | rxq=2

| tc12-IMIX-4t4c-ethip4-ip4base-eth-2vhostvr1024-1vm-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing config with 4 threads, 4 phy\
| | ... | cores, 2 receive queues per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for IMIX_v4_1 frames using single\
| | ... | trial throughput test.
| | ... | IMIX_v4_1 = (28x64B; 16x570B; 4x1518B)
| | ...
| | [Tags] | IMIX | 4T4C | MTHREAD
| | ...
| | [Template] | Check RR for ethip4-ip4base-eth-2vhostvr1024-1vm
| | framesize=IMIX_v4_1 | wt=4 | rxq=2
