#!/bin/bash
###to do: make menu for script to run
chmod +x logo
./logo
echo -n """
WELCOME TO RISHABH'S MONSTER SCRIPT
MAKE SURE YOU KNOW WHAT VERSION/FLAVOR OF LINUX YOU ARE ON!!!!!
WHAT WOULD YOU LIKE TO DO?
1) Firewall (Breaks things)
2) Sysctl configs go brr
3) ubu20 stigs (Can be used in 22 and onwards too) -- DO LAST!!!
4) fstab and grub -- DO LAST!!!
5) LinPEAS (recon)
6) Updates
7) Services
8) Systemd
9) Misc
10) Linux Mega Recon
11) PAM
12) User auditing
"""
read scriptmenu
if [$scriptmenu = "1"]; then
  ./ufw.sh
fi
if [$scriptmenu = "2"]; then
  ./sysctl.sh
fi
if [$scriptmenu = "3"]; then
  ./ubu20stigs.sh
fi
if [$scriptmenu = "4"]; then
  ./grubanddev.sh
fi
if [$scriptmenu = "5"]; then
  ./linpeasscan.sh
fi
if [$scriptmenu = "6"]; then
  ./updates.sh
fi
if [$scriptmenu = "7"]; then
  ./services.sh
fi
if [$scriptmenu = "8"]; then
  ./systemd.sh
fi
if [$scriptmenu = "9"]; then
  ./misc.sh
fi
if [$scriptmenu = "10"]; then
  ./linuxmegarecon.sh
fi
if [$scriptmenu = "11"]; then
  ./pam.sh
fi
if [$scriptmenu = "12"]; then
  ./usermgmt.sh
fi
