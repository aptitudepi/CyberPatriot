#!/bin/bash

echo "Do you want to check any IPs?"
read fquestion
if [ $fquestion == "y" ] || [ $fquestion == "Y" ]; then
  
  cd ~
  touch ipworking.txt
  touch ipnotworking.txt
  read -p "Check IP: " a 
  function checkip
  { 
          ping=`ping -c1 $ip | grep bytes | wc -l`
          if [ "$ping" -gt 1 ];
          then 
            echo "$ip is up"
            echo $ip >> ipworking.txt
          else
            echo "$ip is not up..."
            echo $ip >> ipnotworking.txt
          fi
  }

  checkip
fi
exit 1
#fix it, doesn't work
