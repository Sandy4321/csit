SRv6
====

Following sections include Throughput Speedup Analysis for VPP multi-
core multi-thread configurations with no Hyper-Threading, specifically
for tested 2t2c (2threads, 2cores) and 4t4c scenarios. 1t1c throughput
results are used as a reference for reported speedup ratio. Input data
used for the graphs comes from Phy-to-Phy 78B performance tests with VPP
SRv6, including NDR throughput (zero packet loss) and
PDR throughput (<0.5% packet loss).

NDR Throughput
--------------

VPP NDR 78B packet throughput speedup ratio is presented in the graphs
below for 10ge2p1x520 network interface card.


NIC 10ge2p1x520
~~~~~~~~~~~~~~~

.. raw:: html

    <iframe width="700" height="1000" frameborder="0" scrolling="no" src="../../_static/vpp/10ge2p1x520-78B-srv6-tsa-ndrdisc.html"></iframe>

.. raw:: latex

    \begin{figure}[H]
        \centering
            \graphicspath{{../_build/_static/vpp/}}
            \includegraphics[clip, trim=0cm 8cm 5cm 0cm, width=0.70\textwidth]{10ge2p1x520-78B-srv6-tsa-ndrdisc}
            \label{fig:10ge2p1x520-78B-srv6-tsa-ndrdisc}
    \end{figure}

*Figure 1. Throughput Speedup Analysis - Multi-Core Speedup Ratio - Normalized
NDR Throughput for Phy-to-Phy SRv6.*

CSIT source code for the test cases used for above plots can be found in
`CSIT git repository <https://git.fd.io/csit/tree/tests/vpp/perf/srv6?h=rls1804>`_.

PDR Throughput
--------------

VPP PDR 78B packet throughput speedup ratio is presented in the graphs
below for 10ge2p1x520 network interface card. PDR
measured for 0.5% packet loss ratio.

NIC 10ge2p1x520
~~~~~~~~~~~~~~~

.. raw:: html

    <iframe width="700" height="1000" frameborder="0" scrolling="no" src="../../_static/vpp/10ge2p1x520-78B-srv6-tsa-pdrdisc.html"></iframe>

.. raw:: latex

    \begin{figure}[H]
        \centering
            \graphicspath{{../_build/_static/vpp/}}
            \includegraphics[clip, trim=0cm 8cm 5cm 0cm, width=0.70\textwidth]{10ge2p1x520-78B-srv6-tsa-pdrdisc}
            \label{fig:10ge2p1x520-78B-srv6-tsa-pdrdisc}
    \end{figure}

*Figure 3. Throughput Speedup Analysis - Multi-Core Speedup Ratio - Normalized
PDR Throughput for Phy-to-Phy SRv6.*

CSIT source code for the test cases used for above plots can be found in
`CSIT git repository <https://git.fd.io/csit/tree/tests/vpp/perf/srv6?h=rls1804>`_.
