#!/bin/bash
#echo "Pick what update manager you would like to configure? Enter 1 for GDM3, 2 for LightDM, 3 for SDDM"
#read updatemanager
#if [ $updatemanager == "1" ]; then
#  
#fi
cp ~/pre-configured-files/login.defs /etc/login.defs
echo "Configured login.defs" >> ~/fedora/script.log
