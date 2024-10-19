#!/bin/bash
#Package Management:

#Finding media files
cd ~
touch homemedia.txt
for extension in mp3 txt jpg jpeg png gif bmp wav flac sh mp3 ogg webm pl mp4 swf avi wmv mp4 js java c php cpp tiff pcap py pyc sh AppImage apk deb tar.gz tgz rhost jar c h m3u m4a m4p mpg mpeg o pdf s S Z zip txt zip tar gz tgz 7z ar 3ga aac aiff amr ape arf asf asx cda dvf gp4 gp5 gpx logic m4b midi pcm rec snd sng uax wma wpl zab mkv vob ogv drc gifv mng avi$ qt wmv yuv rm rmvb amv mp4$ m4v mp m?v zav svi 3gp flv f4v
do
  sudo find /home -name *.$extension >> homemedia.txt
done
echo "All files with those extensions have been logged in homemedia.txt" >> script.log

#If you want to go crazy
echo "Do you want to go crazy by looking for bad files on the entire OS? y/n"
read fquestion
if [ $fquestion == "y" ] || [ $fquestion == "Y" ]; then
  touch fullmedia.txt
  for extension in mp3 txt jpg jpeg png gif bmp wav flac ogg webm mp4 swf avi wmv mp4 tiff pcap py pyc rhost tgz php AppImage apk deb tar.gz jar c h m3u m4a m4p mpg mpeg o pdf s S Z zip tar gz tgz 7z ar 3ga aac aiff amr ape arf asf asx cda dvf gp4 gp5 gpx logic m4b midi pcm rec snd sng uax wma wpl zab mkv vob ogv drc gifv mng avi qt wmv yuv rm rmvb amv mp4 m4v mp m?v zav svi 3gp flv f4v
  do
    sudo find / -name *.$extension >> fullmedia.txt
  done
  echo "You crazy person! A log of all of those files is now located in fullmedia.txt. Btw, /var/cache/dictionaries-common/sqspell.php is a system file (it is safe)." >> script.log
fi
echo "finding and reporting any suspicious text files"
for sus in "password" "cvv" "credit" "card" "passwords" "hidden";
do
  find / -name *"$sus"* > ~/susfiles.txt
done
#find / -name '*.mp3' -type f -delete
#find / -name '*.mov' -type f -delete
#find / -name '*.mp4' -type f -delete
#find / -name '*.avi' -type f -delete
#find / -name '*.mpg' -type f -delete
#find / -name '*.mpeg' -type f -delete
#find / -name '*.flac' -type f -delete
#find / -name '*.m4a' -type f -delete
#find / -name '*.flv' -type f -delete
#find / -name '*.ogg' -type f -delete
#find /home -name '*.gif' -type f -delete
#find /home -name '*.png' -type f -delete
#find /home -name '*.jpg' -type f -delete
#find /home -name '*.jpeg' -type f -delete
cd / && ls -laR 2> /dev/null | grep rwxrwxrwx | grep -v "lrwx" &> ~/777s

#looking for script files
cd ~
touch scriptfiles.txt
for sfile in pl java js html py pyc rpm libc c cpp sh bat tar tar.gz vbs apk ssh/ ssh id_rsa pub pem
do
  sudo find / -name *.$sfile >> scriptfiles.txt
done
echo "All script files with the extensions specified have been logged in scriptfiles.txt" >> script.log
#removing common malware
#sudo apt install bum -y
#echo "Installed BUM." >> script.log
touch badpackages.txt
for badpkg in netcat socat nc p0f ncat etherwake zangband netdiag 4g8 tkiptun-ng wapiti zeitgeist httptunnel w3af acccheck airodump-ng knocker bettercap airgraph openarena airdecloak airbase airtun airolib logkeys rstatd talk ntalk rexec airserv rlogin remote rainbow webinspect burp cain abel openvas intruder netstumbler netsparker acunetix invicti lighttpd zenmap nmap vtgrab amass iptables-persistent autofs nfs persistent wesside rsh rhs-server rsh-client rsh-redone-client snmp sbd prelink pastebinit p0f xserver-xorg xorg opensmtp goldeneye rsync x11vnc wordpress nfs acccheck potator polenum cryptocat arp-scan spraywmi trevorc2 pluginhook fuzzbunch spiderfoot poshc2 sniper buttercap phishery powersploit 3proxy tplmap exploit-db findsploit cmospwd braa w3af tftpd rhythmbox vlc snarf fido fimap pykek atftpd nis yp-tools vpnc sock socket tftpd john john-data bind9 hydra nikto pumpa nmap zenmap wireshark dovecot ettercap kismet logkeys telnet iodine vinagre tightvncserver medusa vino rdesktop trojan hack fcrackzip nginx ophcrack logkeys empathy squid gimp imagemagick portmap rpcbind autofs ciphesis freeciv minetest wesnoth talk talkd kdump-tools kexec-tools deluge yersinia linuxdcpp rfdump aircrack-ng weplab routersploit airgeddon wifite dnsrecon dsniff dnstracer pig fern sn1per pop3 sendmail lcrack pdfcrack fcrackzip pyrit sipcrack rarcrack spyrix abyss ethereumjs-tx irpas inetd openbsd-inetd xinetd ftp syslogd ping talk talkd telnet tomcat postfix postgresql dnsmasq vnc nmdb dhclient sqlmap nmap vuze Vuze frostwire kismet minetest medusa hydra truecrack crack cryptcat torrent transmission tixati frostwise irssi snort burp maltego fern niktgo metasploit owasp sparta zarp scapy pret praeda sploit impacket dnstwist rshijack pwnat tgcd iodine buster dirb dnsrecon wifite airgeddon cowpatty boopsuite bully weevely3 vtgrab cyphesis tftpd atftpd tftpd-hpa 
do
  #sudo apt-get autoremove --purge "$badpkg"* -y
  dpkg -l | grep $badpkg >> ~/badpackages.txt
done
comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u) > ~/manuallyinstalled.txt
rm -i /usr/bin/nc
echo "Generally/potential bad packages reported/removed!" >> script.log

#to clean stuff
sudo apt-get autoremove
echo "Packages cleaned-up, check Boot-Up Manager for more info" >> script.log


#Removing games
for game in gnome-mines aisleriot gnome-mahjongg gnome-nibbles nexuiz darkplaces five-or-more hitori lightsoff swell-foop gnome-taquin defendguin crack-attack airstrike doomsday dopewars empire wing monopd gnome-robots gnome-klotski gnome-sudoku iagno quadrapassel gameconqueror gnome-chess four-in-a-row gnome-tetravex gnome-hitori
do
  sudo apt-get autoremove --purge "$game"* -y
done
echo "Games successfully deleted." >> script.log

#installing malware detection tools
apt-get install chkrootkit clamav rkhunter apparmor apparmor-profiles gufw  hardinfo portsentry lynis sysv-rc-conf nessus -y
rkhunter --update
rkhunter --propupd

#listing antivirus commands
touch ~/Desktop/antiviruscommands.txt
echo -e "USE SUDO\n\nchkrootkit -q\n----------\nlynis -c -quiet\n----------\nrkhunter --update\nrkhunter --propupd\nrkhunter -c --enable all --disable none\n----------\nclamscan -r --bell -i /" > ~/Desktop/antiviruscommands.txt
chmod 777 ~/Desktop/antiviruscommands.txt
echo "Antivirus commands can be found in antiviruscommands.txt" >> ~/script.log

#apparmor
if ! grep 'session.*pam_apparmor.so order=user,group,default' /etc/pam.d/*; then
  echo 'session optional pam_apparmor.so order=user,group,default' > /etc/pam.d/apparmor
fi
DEFAULTGRUB='/etc/default/grub.d'
if ! grep -q 'apparmor=1' /proc/cmdline; then
  echo "GRUB_CMDLINE_LINUX=\"\$GRUB_CMDLINE_LINUX apparmor=1 security=apparmor\"" > "$DEFAULTGRUB/99-hardening-apparmor.cfg"
fi

systemctl enable apparmor.service
systemctl restart apparmor.service

find /etc/apparmor.d/ -maxdepth 1 -type f -exec aa-enforce {} \;

if [[ $VERBOSE == "Y" ]]; then
  systemctl status apparmor.service --no-pager
  echo
fi

#lynis
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
echo "Lynis scan complete" >> script.log

#clamav
echo "NEED TO TEST"
freshclam
cd ~
touch clamscan.txt
systemctl stop clamav-freshclam
freshclam --stdout
systemctl start clamav-freshclam
clamscan -r --bell -i / >> clamscan.txt
touch clamlog.txt /home/logs/
clamscan --infected --detect-pua=yes --recursive --verbose | tee clamlog.txt
echo "clamscan complete" >> script.log

#clamtk install


echo "package management script completed!" >> script.log
