#!/bin/bash

# Display the welcome message and menu
chmod +x logo
./logo
echo -n """
WELCOME TO RISHABH'S MONSTER SCRIPT
MAKE SURE YOU KNOW WHAT VERSION/FLAVOR OF LINUX YOU ARE ON!!!!!
WHAT WOULD YOU LIKE TO DO?
1. Account + Local Policy - PAM --> (NO PAM IS CONFIGURED HERE) (vulncats too confusing so just bear with this)
2. Application Security Settings + firefox security (critical services --> work in progress)
3. Operating System + Application Updates (NEED TO ADD KERNEL UPDATE!!! MISSING!!!)
4. Defensive Countermeasures
5. Malware (recon goes brr)
6. Prohibited Files
7. Unwanted Software (run this before 6)
8. Service Auditing (sysctl.sh also takes care of some, so run before this)
9. Uncategorized Operating System Settings (+ kernel hardening)
10. User Auditing
11. PAM :skull:
12. Grub
"""
read -p "Enter your choice: " scriptmenu

# Process user input
if [[ $scriptmenu = "1" ]]; then
    # /etc/login.defs
    mv /etc/login.defs /etc/login.defs.bak
    mv ~/pre-configured-files/login.defs /etc/login.defs
    chmod 644 /etc/login.defs

    # /etc/sysctl.conf
    echo "hardening sysctl"
    ./sysctl.sh

    # /etc/lightdm/lightdm.conf
    mv /etc/lightdm/lightdm.conf /etc/lightdm/lightdm/conf.bak
    mv ~/pre-configured-files/lightdm.conf /etc/lightdm/lightdm.conf

    # dconf stuff
    dconf reset -f /
    gsettings set org.gnome.desktop.privacy remember-recent-files false
    gsettings set org.gnome.desktop.media-handling automount false
    gsettings set org.gnome.desktop.media-handling automount-open false
    gsettings set org.gnome.desktop.search-providers disable-external true
    dconf update

    echo "enter the main user of this system (readme)"
    read user

    # screen timeout policy
    sudo -u $user gsettings set org.gnome.desktop.session idle-delay 300
    # auto screen lock
    sudo -u $user gsettings set org.gnome.desktop.screensaver lock-enabled true
fi

if [[ $scriptmenu = "2" ]]; then
    ./firefox.sh
    ./lnmpstack.sh
fi

if [[ $scriptmenu = "3" ]]; then
    echo "sources.list.d"
    ls -la /etc/apt/sources.list.d
    sleep 10
    echo "apt.conf.d"
    ls -la /etc/apt/apt.conf.d
    sleep 10
    echo "do software & updates as well as synaptic if debian"
    sleep 2
    ./updates.sh
    echo "apt install --reinstall critical services after making file backups"
fi

if [[ $scriptmenu = "4" ]]; then
    ./ufw.sh
fi

if [[ $scriptmenu = "5" ]]; then
    echo "run funny recon scripts"
    echo "Installing and running debsums (this may take a while, so feel free to do forensics in the background)"
    sleep 2
    apt install debsums -y
    debsums -ca > ~/debsums.txt
    echo "Installing and running rkhunter"
    sleep 2
    apt install rkhunter -y
    rkhunter -c
    echo "running rkhunter scan 2"
    rkhunter --checkall --sk
    echo "installing and running linpeas"
    sleep 2
    curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh | sh
    echo "installing and running lynis"
    sleep 2
    cd ~
    touch lynis.txt
    touch lynisaudit.txt
    wget https://cisofy.com/files/lynis-3.0.6.tar.gz -O /lynis.tar.gz
    tar -xvzf /lynis.tar.gz --directory /usr/share/
    cd /usr/share/lynis/
    /usr/share/lynis/lynis update info
    /usr/share/lynis/lynis audit system
    sudo lynis -c -Q >> lynis.txt
    sudo lynis audit system >> lynisaudit.txt
    echo "Installing and running chkrootkit"
    sleep 2
    apt install chkrootkit
    chkrootkit -x
    echo "Installing and running blue team scripts"
    bash blueteam/audit.sh
    echo "need to test audit2.sh"
    echo "finding kernel modules (diff this with clean image)"
    find /lib/modules/$(uname -r) -type f -name '*.ko' > ~/kernelmods.txt
    echo "finding kernel modules"
    find /usr/lib/modules/ -name *.ko > ~/kernelmodules.txt
    sleep 1
    echo "installing clamtk"
    sudo apt-get install clamtk -y
    clamtk
fi

if [[ $scriptmenu = "6" ]]; then
    echo "finding and reporting PII"
    ./find_personal_info.sh
fi

if [[ $scriptmenu = "7" ]]; then
    ./packagemgmt.sh
fi

if [[ $scriptmenu = "8" ]]; then
    systemctl disable cups.service
    apt install apparmor -y
    systemctl enable apparmor
    systemctl enable rsyslog
    # systemctl unnecessary services
    systemctl disable cups-browsed
    systemctl disable avahi-daemon
    systemctl stop cups-browsed
    systemctl stop avahi-daemon
fi

if [[ $scriptmenu = "9" ]]; then
    echo "if internet is broken, fix it"
    sleep 2
    nano /etc/resolv.conf
    echo "LLMNR=no"
    sleep 2
    nano /etc/systemd/resolved.conf
    echo "doing more kernel hardening"
    ./kernelrunfirst.sh
    ./grubanddev.sh
    ./kernel.sh
fi

if [[ $scriptmenu = "10" ]]; then
    echo "Running user script"
    sleep 1
    ./usermgmt.sh
    echo "check for bad shells, hidden users, incorrect uids, etc."
    sleep 2
    nano /etc/passwd
    echo "check groups -- esp admins"
    sleep 2
    nano /etc/group
    echo "check for bad hash types in shadow or locked/disabled users"
    sleep 2
    nano /etc/shadow
    passwd -l root
    echo "login.defs is in policy script. You should run that."
    echo "fixing and reporting .bashrc's and .profile's"
    for i in $(find / -name .bashrc | xargs); do
        mv $i ~/$i.bak
        cp ~/pre-configured-files/.bashrc $i
    done
    for i in $(find / -name .profile | xargs); do
        mv $i ~/$i.bak
        cp ~/pre-configured-files/.profile $i
    done
fi

if [[ $scriptmenu = "11" ]]; then
    echo "run this ONLY AFTER #1!"
    sleep 5
    ./pam.sh
    echo "double-checking configs"
    ./password_policy_checks.sh
fi

if [[ $scriptmenu = "12" ]]; then
    ./grubanddev.sh
fi
