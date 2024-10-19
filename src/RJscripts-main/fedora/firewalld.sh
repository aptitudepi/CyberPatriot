#!/bin/bash

dnf install firewalld
systemctl unmask firewalld
systemctl start firewalld
systemctl enable firewalld
sudo firewall-cmd --set-log-denied=all --permanent
sudo firewall-cmd --reload
