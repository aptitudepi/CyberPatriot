#!/bin/bash
apt install --reinstall firefox -y
firefox about:support
echo "open about:support in firefox if this script hasn't opened it already"
echo "Application Basics > Profile Folder"
read -p "enter the profile directory (looks something like this: ~/.mozilla/firefox/[profile_name]):" firefoxprofiledir
filepath=""${firefoxprofiledir}"/user.js"
echo $filepath
cp pre-configured-files/user.js $filepath
echo "also check about:addons for addons and make sure it is gucci"
