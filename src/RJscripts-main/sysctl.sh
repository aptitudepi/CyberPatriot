#IP Spoofing prevented and sysctl configured
cd ~
mv ~/pre-configured-sysctl/sysctl.conf /etc/sysctl.conf
sysctl -n net.ipv4.tcp_syncookies
echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf
sudo echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
sed -i 's/kernel.modules_disabled = 1/kernel.modules_disabled = 0/' /etc/sysctl.conf
sudo echo 1 > /proc/sys/net/ipv4/tcp_syncookies
echo 1 > /proc/sys/net/ipv4/tcp_rfc1337
sudo echo 0 >> /proc/sys/net/ipv4/ip_forward
echo "
kernel.kptr_restrict = 2
kernel.dmesg_restrict = 1
kernel.printk = "3 3 3 3"
kernel.unprivileged_bpf_disabled = 1
net.core.bpf_jit_harden = 2
dev.tty.ldisc_autoload = 0
vm.unprivileged_userfaultfd = 0
kernel.kexec_load_disabled = 1
kernel.sysrq = 0
kernel.unprivileged_userns_clone = 0
kernel.perf_event_paranoid = 3
net.ipv4.conf.all.log_martians = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1 
net.ipv4.route.flush = 1
kernel.randomize_va_space = 2
net.ipv4.conf.all.rp_filter = 1
net.ipv4.icmp_ignore_bogus_error_messages = 1
net.ipv4.icmp_echo_ignore_all = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.ip_no_pmtu_disc = 3
" >> /etc/sysctl.conf
sudo sysctl -w kernel.kptr_restrict=2
sudo sysctl -w kernel.dmesg_restrict=1
sudo sysctl -w kernel.printk="3 3 3 3"
sudo sysctl -w kernel.exec-shield=1
sudo sysctl -w kernel.unprivileged_bpf_disabled=1
sudo sysctl -w net.core.bpf_jit_harden=2
sudo sysctl -w dev.tty.ldisc_autoload=0
sudo sysctl -w vm.unprivileged_userfaultfd=0
sudo sysctl -w kernel.kexec_load_disabled=1
sudo sysctl -w kernel.sysrq=4
sudo sysctl -w kernel.unprivileged_userns_clone=0
sudo sysctl -w kernel.perf_event_paranoid=3
sudo sysctl -w net.ipv4.conf.all.log_martians=1
sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1 
sysctl -w net.ipv4.route.flush=1
sysctl -w net.ipv4.conf.all.rp_filter=1
sudo sysctl -w net.ipv4.tcp_syncookies=1
sysctl -w kernel.randomize_va_space=2
sysctl -w net.ipv4.icmp_ignore_bogus_error_messages=1
sysctl -w net.ipv4.icmp_echo_ignore_all=1
sysctl -w net.ipv4.conf.all.accept_source_route=0
sysctl -w dev.tty.ldisc_autoload=0
sysctl -w fs.protected_fifos=2
sysctl -w fs.protected_hardlinks=1
sysctl -w fs.protected_symlinks=1
sysctl -w fs.suid_dumpable=0
sysctl -w kernel.core_uses_pid=1
sysctl -w kernel.dmesg_restrict=1
sysctl -w kernel.kptr_restrict=2
sysctl -w kernel.panic=60
sysctl -w kernel.panic_on_oops=60
sysctl -w kernel.perf_event_paranoid=3
sysctl -w kernel.randomize_va_space=2
sysctl -w kernel.sysrq=0
sysctl -w kernel.unprivileged_bpf_disabled=1
sysctl -w kernel.yama.ptrace_scope=2
sysctl -w net.core.bpf_jit_harden=2
sysctl -w net.ipv4.conf.all.accept_redirects=0
sysctl -w net.ipv4.conf.all.accept_source_route=0
sysctl -w net.ipv4.conf.all.log_martians=1
sysctl -w net.ipv4.conf.all.rp_filter=1
sysctl -w net.ipv4.conf.all.secure_redirects=0
sysctl -w net.ipv4.conf.all.send_redirects=0
sysctl -w net.ipv4.conf.all.shared_media=0
sysctl -w net.ipv4.conf.default.accept_redirects=0
sysctl -w net.ipv4.conf.default.accept_source_route=0
sysctl -w net.ipv4.conf.default.log_martians=1
sysctl -w net.ipv4.conf.default.rp_filter=1
sysctl -w net.ipv4.conf.default.secure_redirects=0
sysctl -w net.ipv4.conf.default.send_redirects=0
sysctl -w net.ipv4.conf.default.shared_media=0
sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1
sysctl -w net.ipv4.icmp_ignore_bogus_error_responses=1
sysctl -w net.ipv4.ip_forward=0
sysctl -w net.ipv4.tcp_challenge_ack_limit=2147483647
sysctl -w net.ipv4.tcp_invalid_ratelimit=500
sysctl -w net.ipv4.tcp_max_syn_backlog=20480
sysctl -w net.ipv4.tcp_rfc1337=1
sysctl -w net.ipv4.tcp_syn_retries=5
sysctl -w net.ipv4.tcp_synack_retries=2
sysctl -w net.ipv4.tcp_syncookies=1
sysctl -w net.ipv6.conf.all.accept_ra=0
sysctl -w net.ipv6.conf.all.accept_redirects=0
sysctl -w net.ipv6.conf.all.accept_source_route=0
sysctl -w net.ipv6.conf.all.forwarding=0
sysctl -w net.ipv6.conf.all.use_tempaddr=2
sysctl -w net.ipv6.conf.default.accept_ra=0
sysctl -w net.ipv6.conf.default.accept_ra_defrtr=0
sysctl -w net.ipv6.conf.default.accept_ra_pinfo=0
sysctl -w net.ipv6.conf.default.accept_ra_rtr_pref=0
sysctl -w net.ipv6.conf.default.accept_redirects=0
sysctl -w net.ipv6.conf.default.accept_source_route=0
sysctl -w net.ipv6.conf.default.autoconf=0
sysctl -w net.ipv6.conf.default.dad_transmits=0
sysctl -w net.ipv6.conf.default.max_addresses=1
sysctl -w net.ipv6.conf.default.router_solicitations=0
sysctl -w net.ipv6.conf.default.use_tempaddr=2
sysctl -w net.ipv6.conf.eth0.accept_ra_rtr_pref=0
sysctl -w net.filter.nf_conntrack_max=2000000
sysctl -w net.filter.nf_conntrack_tcp_loose=0
sysctl -w kernel.panic=10
sysctl -w kernel.modules_disabled=1
sysctl -w net.ipv4.ip_no_pmtu_disc = 3

systemctl disable rpcbind
#systemctl disable vsftpd
#systemctl disable apache2
systemctl disable dovecot
systemctl disable smbd
systemctl disable squid
systemctl disable snmpd
systemctl disable rsync
systemctl disable nis
#service apache2 stop
#systemctl disable apache2
service nginx stop
systemctl disable nginx
#service vsftpd stop
#systemctl disable vsftpd
service rsh stop
systemctl disable rsh
service cups stop
#systemctl disable xinetd
#service isc-dhcp-server stop
systemctl disable isc-dhcp-server
service  nfs-server stop
systemctl disable  nfs-server
#service rpcbind stop
#systemctl disable rpcbind
service bind9 stop
systemctl disable bind9
service smbd stop
systemctl disable smbd
service rsync stop
systemctl disable rsync
service nis stop
systemctl disable nis
service squid stop
systemctl disable squid
service nfs disable
service pop3 disable
service iptables-persistent stop
systemctl disable iptables-persistent
systemctl disable avahi-daemon
sudo sysctl -e -p /etc/sysctl.conf
sysctl restart systemd-sysctl
sudo chmod 600 /etc/sysctl.conf
journalctl -xe > ~/sysctljournalctlcheck.txt
echo "sysctl configured...if you lose points for taking a service down, just bring it back up" >> ~/script.log
