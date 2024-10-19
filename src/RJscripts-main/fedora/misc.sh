#!/bin/bash
echo "set apply_updates to yes"
sleep 2
env EDITOR='gedit -w' sudoedit /etc/dnf/automatic.conf
sudo dnf install dnf-automatic
systemctl enable --now dnf-automatic.timer
systemctl list-units --type=service > ~/fedora_sysctl_services.txt
sudo lsof -i -P -n | grep -v "(ESTABLISHED)" > ~/fedora_lsof_established.txt
sudo lsof -i -P -n | grep -v "(LISTEN)" > ~/fedora_lsof_listen.txt

sudo dnf install rkhunter
sudo rkhunter --update
sudo rkhunter -c > ~/fedora_rkhunter.txt
