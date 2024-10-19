#!/bin/bash
iptables -L
echo "these are existing settings"
iptables-save > beforehardeningiptables
sleep 2
# Flush existing rules and set default policies
iptables -F
iptables -X
iptables -Z
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# Allow established connections
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow loopback traffic
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Prompt to allow specific services
read -p "Allow SSH? [Y/N]: " allow_ssh
read -p "Allow HTTP? [Y/N]: " allow_http
read -p "Allow HTTPS? [Y/N]: " allow_https

# Allow SSH (if selected)
if [[ $allow_ssh =~ ^[Yy]$ ]]; then
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT
    iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT
fi

# Allow HTTP (if selected)
if [[ $allow_http =~ ^[Yy]$ ]]; then
    iptables -A INPUT -p tcp --dport 80 -j ACCEPT
    iptables -A OUTPUT -p tcp --sport 80 -j ACCEPT
fi

# Allow HTTPS (if selected)
if [[ $allow_https =~ ^[Yy]$ ]]; then
    iptables -A INPUT -p tcp --dport 443 -j ACCEPT
    iptables -A OUTPUT -p tcp --sport 443 -j ACCEPT
fi

# Block all other inbound traffic
iptables -A INPUT -j DROP

# Save iptables rules
iptables-save > /etc/iptables/rules.v4
