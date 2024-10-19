# 2021-CyberPatriot-Scripts-Linux-New
Plan of action:
1. Read README and answer forensics questions
2. DONT Run configs.sh
3. Run firewall.sh
4. Run usermgmt.sh
5. Run packagemgmt.sh
6. Run misc.sh
7. Run services.sh
8. (Optional) Run lamp.sh -- ADD mysql, php configs


TODO LIST:
-- add more configs for services such as postfix, nfs, dovecot, and other obscure ones
-- work on recon on the system itself
-- try adding more stuff on turning services on and off (alr have it, but is scattered among my many scripts -- work on consolidating it)

Notes:

-- should do `chattr -R /directoryname/* for config dirs and files that should not be immutable in a dir`

rd3 stuff to look for

-- file perms

-- SUIDs

-- make sure to read through the config files carefully such as /etc/passwd and what not

-- harder crontabs

-- check for bootloaders

   -- check grub, fstab, mounted devices

-- check for backdoors/malicious scripts in /etc/init.d

-- random media files

-- check through ps aux, netstat, etcetera


-- just answer forensics, read README, checklists, scripts

-- linpeas and stuff if u run out of stuff


Notes:
- look through fstab
- fix pam
-- nginx: https://hostadvice.com/how-to/how-to-harden-nginx-web-server-on-ubuntu-18-04/

https://wiki.ubuntu.com/Security/Features

https://github.com/trimstray/linux-hardening-checklist/blob/master/README.md

https://github.com/konstruktoid/hardening

https://madaidans-insecurities.github.io/guides/linux-hardening.html






