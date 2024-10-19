#!/bin/bash
#update the pkgs
sudo apt update -y
#install ua, attach to my free sub, and enable usg
sudo apt install ubuntu-advantage-tools
sudo ua attach C13mSFCcnKKi3ePDqgBWTdqBMZoguz
sudo ua enable usg
#install usg and openscap
sudo apt install usg* -y
sudo apt install usg-cisbenchmark -y
sudo apt install libopenscap8 -y
#update to reinforce
sudo apt update -y
#start audits!
cd /usr/share/ubuntu-scap-security-guides/
sudo usg audit cis_level1_server > ~/cisL1serv.txt
sudo usg audit cis_level1_workstation > ~/cisL1workstation.txt
sudo usg audit cis_level2_server > ~/cisL2serv.txt
sudo usg audit cis_level2_workstation > ~/cisL2workstation.txt
sudo usg audit disa_stig > ~/cisDisa-Stig.txt
echo "WATCH https://www.youtube.com/watch?v=wyEX0eyoK88 for configs and stuff and google how to pass the rules that are failed!" >> ~/script.log
echo "cis audits complete" >> ~/script.log
