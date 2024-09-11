#!/bin/bash

FILE="sudo.txt"
FILEval=$(<sudo.txt)
$str1
$str2
$str3
$set1
$menENTRY
$UPmenENTRY

CPYN(){
clear
read -p "Update password for sudo commands?:[y/n] " set1
	if [ $set1 == "y" ]; then
		echo "Yes"
		setpass
	elif [ $set1 == "yes" ]; then
		echo "Yes"
		setpass
	elif [ $set1 == "Yes" ]; then
		echo "Yes"
		setpass
	elif [ $set1 == "Y" ]; then
		echo "Yes"
		setpass
	elif [ $set1 == "YES" ]; then
		echo "Yes"
		setpass
	elif [ $set1 == "no" ]; then
		echo "No"
		MM
	elif [ $set1 == "No" ]; then
		echo "No"
		MM
	elif [ $set1 == "n" ]; then
		echo "No"
		MM
	elif [ $set1 == "NO" ]; then
		echo "No"
		MM
	elif [ $set1 == "N" ]; then
		echo "No"
		MM
	else
		echo "Not an option!"
		CPYN
	fi
}

update(){
str3=$FILEval
echo -e "\e[4mUpdating:\e[0m"
echo ""
echo $str3 | sudo -S apt-get --assume-yes update
}

upgrade(){
str3=$FILEval
echo -e "\e[4mUpgrading:\e[0m"
echo ""
echo $str3 | sudo -S apt-get --assume-yes upgrade
}

fullUPGRADE(){
str3=$FILEval
echo -e "\e[4mFull-Upgrade:\e[0m"
echo ""
echo $str3 | sudo -S apt-get --assume-yes full-upgrade
}

upMENcheck(){
read -p "Choose an option: " UPmenENTRY
	if [ $UPmenENTRY == "1" ]; then
		update
	elif [ $UPmenENTRY == "update" ]; then
		update
	elif [ $UPmenENTRY == "Update" ]; then
		update
	elif [ $UPmenENTRY == "UPDATE" ]; then
		update
	elif [ $UPmenENTRY == "2" ]; then
		upgrade
	elif [ $UPmenENTRY == "upgrade" ]; then
		upgrade
	elif [ $UPmenENTRY == "Upgrade" ]; then
		upgrade
	elif [ $UPmenENTRY == "UPGRADE" ]; then
		upgrade
	elif [ $UPmenENTRY == "3" ]; then
		fullUPGRADE
	elif [ $UPmenENTRY == "full" ]; then
		fullUPGRADE
	elif [ $UPmenENTRY == "Full" ]; then
		fullUPGRADE
	elif [ $UPmenENTRY == "FULL" ]; then
		fullUPGRADE
	elif [ $UPmenENTRY == "Full Upgrade" ]; then
		fullUPGRADE
	elif [ $UPmenENTRY == "full upgrade" ]; then
		fullUPGRADE
	elif [ $UPmenENTRY == "fullupgrade" ]; then
		fullUPGRADE
	elif [ $UPmenENTRY == "FULLUPGRADE" ]; then
		fullUPGRADE
	elif [ $UPmenENTRY == "FULL UPGRADE" ]; then
		fullUPGRADE
	elif [ $UPmenENTRY == "full-upgrade" ]; then
		fullUPGRADE
	elif [ $UPmenENTRY == "FULL-UPGRADE" ]; then
		fullUPGRADE
	elif [ $UPmenENTRY == "f" ]; then
		fullUPGRADE
	elif [ $UPmenENTRY == "F" ]; then
		fullUPGRADE
	elif [ $UPmenENTRY == "4" ]; then
		MM
	elif [ $UPmenENTRY == "b" ]; then
		MM
	elif [ $UPmenENTRY == "B" ]; then
		MM
	elif [ $UPmenENTRY == "BACK" ]; then
		MM
	elif [ $UPmenENTRY == "back" ]; then
		MM
	elif [ $UPmenENTRY == "Back" ]; then
		MM
	else
		echo "Not an option!"
		echo "Try again in 3 seconds"
		sleep 3
		upMEN
	fi
}

upMEN(){
clear
wel
echo "1) Update"
echo "2) Upgrade"
echo "3) Full-Upgrade"
echo "4) Back"
echo "..."
echo ""
upMENcheck
}

menCHECK(){
read -p "Choose an option: " menENTRY
	if [ $menENTRY == "1" ]; then
		all
	elif [ $menENTRY == "EVERYTHING" ]; then
		all
	elif [ $menENTRY == "Everything" ]; then
		all
	elif [ $menENTRY == "everything" ]; then
		all
	elif [ $menENTRY == "2" ]; then
		up
	elif [ $menENTRY == "3" ]; then
		upMEN
	elif [ $menENTRY == "4" ]; then
		help
	elif [ $menENTRY == "H" ]; then
		help
	elif [ $menENTRY == "h" ]; then
		help
	elif [ $menENTRY == "HELP" ]; then
		help
	elif [ $menENTRY == "help" ]; then
		help
	elif [ $menENTRY == "Help" ]; then
		help
	elif [ $menENTRY == "5" ]; then
		setpass
	elif [ $menENTRY == "set" ]; then
		setpass
	elif [ $menENTRY == "SET" ]; then
		setpass
	elif [ $menENTRY == "Set" ]; then
		setpass
	elif [ $menENTRY == "Pass" ]; then
		setpass
	elif [ $menENTRY == "PASS" ]; then
		setpass
	elif [ $menENTRY == "pass" ]; then
		setpass
	elif [ $menENTRY == "password" ]; then
		setpass
	elif [ $menENTRY == "PASSWORD" ]; then
		setpass
	elif [ $menENTRY == "Password" ]; then
		setpass
	elif [ $menENTRY == "Set Password" ]; then
		setpass
	elif [ $menENTRY == "set password" ]; then
		setpass
	elif [ $menENTRY == "SET PASSWORD" ]; then
		setpass
	elif [ $menENTRY == "Set password" ]; then
		setpass
	else
		echo "Not an option!"
		echo "Try again in 3 seconds"
		sleep 3
		MM
	fi
}

all(){
up
}

help(){
echo "helping you out"
}

MM(){
clear
wel
echo "1) Everything"
echo "2) Update and upgrade"
echo "3) Update options menu"
echo "4) Help"
echo "5) Set password"
echo "..."
echo ""
menCHECK
}

up(){
str3=$FILEval
echo -e "\e[4mUpdating:\e[0m"
echo ""
echo $str3 | sudo -S apt-get --assume-yes update
echo ""
echo -e "\e[4mUpgrading:\e[0m"
echo ""
echo $str3 | sudo -S apt-get --assume-yes upgrade
echo ""
echo -e "\e[4mFull-Upgrade:\e[0m"
echo ""
echo $str3 | sudo -S apt-get --assume-yes full-upgrade
echo ""
MM
}

checkpass(){
if [ -f "$FILE" ];	then
	echo 'File "sudo.txt" found!'
	echo ""
	str3=$FILEval
	echo "Your password for sudo is currently set to: " $str3
	echo ""
	changepassYN
else
	echo 'File "sudo.txt" not found!'
	echo ""
	changepassYN
fi	
}
disPASS(){
echo "Your password for sudo =" $str3
echo ""
}
str3set(){
str3=$str2
echo "Your password for sudo = " $str3
echo $str3 > sudo.txt
echo ""
MM
}

passretry(){
echo "Retrying in 3s..."
sleep 3
setpass
}

ctrlc(){
echo -e "\e[4mYou can always press CTRL+C to quit.\e[0m"
echo ""
}

yn(){
clear
wel
read -p 'Set "'$str2'" as password for sudo commands?:[y/n] ' set1
	if [ $set1 == "y" ]; then
		echo "Yes"
		str3set
	elif [ $set1 == "yes" ]; then
		echo "Yes"
		str3set
	elif [ $set1 == "Yes" ]; then
		echo "Yes"
		str3set
	elif [ $set1 == "Y" ]; then
		echo "Yes"
		str3set
	elif [ $set1 == "YES" ]; then
		echo "Yes"
		str3set
	elif [ $set1 == "no" ]; then
		echo "No"
		passretry
	elif [ $set1 == "No" ]; then
		echo "No"
		passretry
	elif [ $set1 == "n" ]; then
		echo "No"
		passretry
	elif [ $set1 == "NO" ]; then
		echo "No"
		passretry
	elif [ $set1 == "N" ]; then
		echo "No"
		passretry
	else
		echo "Not an option!"
		passretry
	fi
}

wel(){
echo "   ______      __              ______     _                "
echo "  / ____/_  __/ /_  ___  _____/ ____/____(_)___  ____ ____ "
echo " / /   / / / / __ \/ _ \/ ___/ /   / ___/ / __ \/ __ '/ _ \ "
echo "/ /___/ /_/ / /_/ /  __/ /  / /___/ /  / / / / / /_/ /  __/"
echo "\____/\__, /_.___/\___/_/   \____/_/  /_/_/ /_/\__, /\___/ "
echo "     /____/                                   /____/       "
echo ""
ctrlc
disPASS
}

setpass(){
clear
wel

read -p "Enter the admin password: " str1
read -p "Re-enter the admin password: " str2

if [ $str1 == $str2 ]; then
	echo "Passwords match!"
	yn
elif [ $str1 != $str2 ]; then
	echo "Try again, passwords do not match!"
	echo "Retrying in 3s..."
	sleep 3
	setpass
fi
}
CPYN
