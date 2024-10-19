#!/bin/bash

#Run after Forensics Questions:
#User Management:

echo "Type all users (EXCEPT YOURSELF!!!) (ON THE SYSTEM RN) with a space in between"
read -a users

usersLength=${#users[@]}	

for (( i=0;i<$usersLength;i++))
do
	clear
	usermod --shell /bin/bash ${users[${i}]}
	sudo chage -d 0 ${users[${i}]}
	sudo passwd -e ${users[${i}]}
	cat ~/pre-configured-files/.bashrc > "/home/${users[${i}]}/.bashrc"
	cat ~/pre-configured-files/.profile > "/home/${users[${i}]}/.profile"
	echo ${users[${i}]}
	echo Delete ${users[${i}]}? y or n
	read yn1
	if [ $yn1 == y ]
	then
		sudo deluser ${users[${i}]}
		crontab -r -u ${users[${i}]}
		lprm ${users[${i}]}
		killall -KILL -u ${users[${i}]}
		echo "${users[${i}]} deleted." >> script.log
	else	
		echo Make ${users[${i}]} administrator? y or n
		read yn2								
		if [ $yn2 == y ]
		then
			gpasswd -a ${users[${i}]} sudo
			gpasswd -a ${users[${i}]} lpadmin
			gpasswd -a ${users[${i}]} adm
			gpasswd -a ${users[${i}]} sambashare
			echo "${users[${i}]} is now an administrator." >> script.log
		else
			gpasswd -d ${users[${i}]} sudo
			gpasswd -d ${users[${i}]} lpadmin
			gpasswd -d ${users[${i}]} adm
			gpasswd -d ${users[${i}]} sambashare
			gpasswd -d ${users[${i}]} root
			echo "${users[${i}]} is now a standard user." >> script.log
		fi
		
		echo "Give password to ${users[${i}]}? y or n"
		read yn3								
		if [ $yn3 == y ]
		then
			echo "here, enter this as password thru passwd: CyB3Rp4tr10t!cYberPaT"
			sleep 15
			#passwd ${users[${i}]}
			passwd ${users[${i}]}
			#echo "CyB3Rp4tr10t!cYberPaT\nCyB3Rp4tr10t!cYberPaT" | passwd ${users[${i}]}
			#echo "${users[${i}]} has been given the password 'CyB3Rp4tr10t^cYberPaT'."
		else
			#echo -e "CyB3Rp4tr10t!cYberPaT\nCyB3Rp4tr10t!cYberPaT" >> script.log ##| passwd ${users[${i}]}
			#echo "${users[${i}]} has been given the password 'CyB3Rp4tr10t!cYberPaT'." >> script.log
   			echo "ok buddy"
		fi
		sudo passwd -x15 -n7 -w7 ${users[${i}]}
		sudo chage -M 15 -m 7 -W 7 ${users[${i}]}
		sudo chsh ${users[${i}]} /bin/bash
		#usermod -L ${users[${i}]}
		echo "${users[${i}]}'s password set to 15-7-7 and shell changed to /bin/bash." >> script.log
	fi
done
clear

echo "Type names of users you want to add (SPECIFIED BY README) with a space in between"
read -a usersAdd

usersAddLength=${#usersAdd[@]}	

for (( i=0;i<$usersAddLength;i++))
do
	clear
	echo ${usersAdd[${i}]}
	sudo adduser ${usersAdd[${i}]}
	echo "A user account for ${usersAdd[${i}]} has been created." >> script.log
	clear
	echo Make ${usersAdd[${i}]} administrator? y or n
	read ynAdd								
	if [ $ynAdd == y ]
	then
		gpasswd -a ${usersAdd[${i}]} sudo
		gpasswd -a ${usersAdd[${i}]} lpadmin
		gpasswd -a ${usersAdd[${i}]} adm
		gpasswd -a ${usersAdd[${i}]} sambashare
		echo "${usersAdd[${i}]} has been made an administrator." >> script.log
	else
		echo "${usersAdd[${i}]} has been made a standard user." >> script.log
	fi
	
	sudo passwd -x15 -n7 -w7 ${usersAdd[${i}]}
	sudo chage -M 15 -m 7 -W 7 ${usersAdd[${i}]}
	sudo chsh ${usersAdd[${i}]} /bin/bash
	#usermod -L ${usersAdd[${i}]}
	echo "${usersAdd[${i}]}'s password set to 15-7-7 and shell changed to /bin/bash." >> script.log
done

echo "Type all users you want to add to a group (specify the group name when prompted)"
read -a addusertogroup

usersLength=${#addusertogroup[@]}

for (( i=0;i<$usersLength;i++))
do
	echo "what is the name of the group you want to add ${addusertogroup[${i}]} to?"
	read -a groupname
	sudo addgroup $groupname # make sure group exists
	sudo usermod -aG $groupname ${addusertogroup[${i}]} # add that user to that group
done
###Finding shadowroot
cd ~
touch shadowroot.txt
cut -d: -f1,3 /etc/passwd | egrep ':0$' | cut -d: -f1 | grep -v root > shadowroot.txt
clear
echo "Please check ~/shadowroot.txt and remove those bad users!" >> ~/script.log

cat /etc/passwd | cut -d ":" -f 1,7 > ~/usershell.txt

#cd ~
#touch admins.txt
#echo "pls enter all admin separated by newline"
#sleep 10
#nano admins.txt
#for line in $(cat /etc/passwd | grep "/bin/bash" | cut -d ":" -f 1)
#do
#	if ! grep -q $line ~/admin.txt 
#	then
#		
#	fi
#done
#cd ~
#echo "pls enter all users separated by newline"
#sleep 10
#nano users.txt
#for line in $(cat /etc/passwd | grep "/bin/bash" | cut -d ":" -f 1)
#do
#	if ! grep -q $line ~/users.txt && 
#	
#	fi
#done

USERADD='/etc/default/useradd'
ADDUSER='/etc/adduser.conf'
sed -i -e 's/^DIR_MODE=.*/DIR_MODE=0750/' -e 's/^#DIR_MODE=.*/DIR_MODE=0750/' "$ADDUSER"
sed -i -e 's/^DSHELL=.*/DSHELL=\/bin\/false/' -e 's/^#DSHELL=.*/DSHELL=\/bin\/false/' "$ADDUSER"
sed -i -e 's/^USERGROUPS=.*/USERGROUPS=yes/' -e 's/^#USERGROUPS=.*/USERGROUPS=yes/' "$ADDUSER"

sed -i 's/^SHELL=.*/SHELL=\/bin\/false/' "$USERADD"
sed -i 's/^# INACTIVE=.*/INACTIVE=30/' "$USERADD"

awk -F ':' '{if($3 >= 1000 && $3 <= 65000) print $6}' /etc/passwd | while read -r userhome; do
  chmod 0750 "$userhome"
done

usermod -L root
echo "lock root acc"
if [[ $VERBOSE == "Y" ]]; then
  passwd -S root
  echo
fi
clear
