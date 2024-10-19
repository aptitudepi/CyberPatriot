#!/bin/bash
firefox https://github.com/konstruktoid/hardening/blob/master/systemd.adoc
systemd-analyze security > ~/systemdsecurityanalysis.txt
echo "
[Journal]
Compress=yes // (1)
ForwardToSyslog=yes // (2)
Storage=persistent // (3)
" >> /etc/systemd/journald.conf
echo "
[Coredump]
Storage=none // (1)
ProcessSizeMax=0 // (2)
" >> /etc/systemd/coredump.conf
echo "
[Unit]
Description=Temporary Directory
Documentation=man:hier(7)
Before=local-fs.target

[Mount]
What=tmpfs // (1)
Where=/tmp // (2)
Type=tmpfs // (3)
Options=mode=1777,strictatime,nodev,noexec,nosuid // (4)(5)
" >> /etc/systemd/system/tmp.mount

echo "
[Resolve]
DNS=127.0.0.1 // (1)
FallbackDNS=1.1.1.1 1.0.0.1 // (2)
DNSSEC=allow-downgrade // (3)
DNSOverTLS=opportunistic // (4)
" >> /etc/systemd/resolved.conf

echo "
[Manager]
DumpCore=no // (1)
CrashShell=no // (2)
DefaultLimitCORE=0 // (3)
DefaultLimitNOFILE=100 // (4)
DefaultLimitNPROC=100 // (5)
CtrlAltDelBurstAction=none // (6)
" >> /etc/systemd/system.conf

echo "
[Time]
NTP=0.ubuntu.pool.ntp.org 1.ubuntu.pool.ntp.org // (1)
FallbackNTP=2.ubuntu.pool.ntp.org 3.ubuntu.pool.ntp.org // (2)
RootDistanceMaxSec=1 // (3)
" >> /etc/systemd/timesyncd.conf

echo "
[Login]
KillUserProcesses=1 // (1)
KillExcludeUsers=root // (2)
IdleAction=lock // (3)
IdleActionSec=15min // (4)
RemoveIPC=yes // (5)
" >> /etc/systemd/logind.conf

echo "
[Manager]
DefaultLimitCORE=0 // (1)
DefaultLimitNOFILE=100 // (2)
DefaultLimitNPROC=100 // (3)
CapabilityBoundingSet=~CAP_SYS_PTRACE // (4)
" >> /etc/systemd/user.conf





