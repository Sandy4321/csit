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
*** Settings ***
| Library | resources.libraries.python.QemuUtils
| Library | resources.libraries.python.ssh.SSH

*** Keywords ***

| QEMU build list should exist
| | [Documentation] | Return TRUE if variable QEMU_BUILD exist, otherwise FALSE
| | ${ret} | ${tmp}=  | Run Keyword And Ignore Error
| | ... | Variable Should Exist | @{QEMU_BUILD}
| | Return From Keyword If | "${ret}" == "PASS" | ${TRUE}
| | Return From Keyword | ${FALSE}

| Is QEMU ready on node
| | [Documentation] | Check if QEMU was built on the node before
| | [Arguments] | ${node}
| | ${ret}= | QEMU build list should exist
| | Return From Keyword If | ${ret} == ${FALSE} | ${FALSE}
| | ${ret} | ${tmp}=  | Run Keyword And Ignore Error
| | ... | Should Contain | ${QEMU_BUILD} | ${node['host']}
| | Return From Keyword If | "${ret}" == "PASS" | ${TRUE}
| | Return From Keyword | ${FALSE}

| Add node to QEMU build list
| | [Documentation] | Add node to the list of nodes with builded QEMU (global
| | ...             | variable QEMU_BUILD)
| | [Arguments] | ${node}
| | ${ret}= | QEMU build list should exist
| | Run Keyword If | ${ret} == ${TRUE}
| | ... | Append To List | ${QEMU_BUILD} | ${node['host']}
| | ... | ELSE | Set Global Variable | @{QEMU_BUILD} | ${node['host']}

| Build QEMU on node
| | [Documentation] | Build QEMU from sources on the Node. Nodes with successful
| | ...             | QEMU build are stored in global variable list QEMU_BUILD
| | ...
| | ... | *Arguments:*
| | ... | - node - Node on which to build qemu. Type: dictionary
| | ... | - force_install - If True, then remove previous build. Type: bool
| | ... | - apply_patch - If True, then apply patches from qemu_patches dir.
| | ... | Type: bool
| | ...
| | ... | *Example:*
| | ...
| | ... | \| Build QEMU on node \| ${node['DUT1']} \| False \| False \|
| | ...
| | [Arguments] | ${node} | ${force_install}=${False} | ${apply_patch}=${False}
| | ${ready}= | Is QEMU ready on node | ${node}
| | Return From Keyword If | ${ready} == ${TRUE}
| | Build QEMU | ${node}
| | Add node to QEMU build list | ${node}

| Build QEMU on all DUTs
| | [Documentation] | Build QEMU from sources on all DUTs. Nodes with successful
| | ...             | QEMU build are stored in global variable list QEMU_BUILD
| | ...
| | ... | *Arguments:*
| | ... | - force_install - If True, then remove previous build. Type: bool
| | ... | - apply_patch - If True, then apply patches from qemu_patches dir.
| | ... | Type: bool
| | ...
| | ... | *Example:*
| | ...
| | ... | \| Build QEMU on all DUTs \| False \| False \|
| | ...
| | [Arguments] | ${force_install}=${False} | ${apply_patch}=${False}
| | ${duts}= | Get Matches | ${nodes} | DUT*
| | :FOR | ${dut} | IN | @{duts}
| | | Build QEMU on node | ${nodes['${dut}']} | ${force_install} |
| | | ... | ${apply_patch}

| Stop and clear QEMU
| | [Documentation] | Stop QEMU, clear used sockets and close SSH connection
| | ...             | running on ${dut}, ${vm} is VM node info dictionary
| | ...             | returned by qemu_start or None.
| | [Arguments] | ${dut} | ${vm}
| | Qemu Set Node | ${dut}
| | Qemu Kill
| | Qemu Clear Socks
| | Run Keyword If | ${vm} is not None | Disconnect | ${vm}

| Kill Qemu on all DUTs
| | [Documentation] | Kill QEMU processes on all DUTs.
| | ${duts}= | Get Matches | ${nodes} | DUT*
| | :FOR | ${dut} | IN | @{duts}
| | | Qemu Set Node | ${nodes['${dut}']}
| | | Qemu Kill
