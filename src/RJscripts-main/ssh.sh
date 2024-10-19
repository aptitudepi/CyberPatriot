mv /etc/sshd_config /etc/sshdconfig.bak
cp ~/pre-configured-files/sshd_config /etc/ssh/sshd_config
echo "enter the name of the group you want to create:"
read addgroupssh
addgroup $addgroupssh
echo "enter the group to allow SSH for:"
read groupssh
echo "AllowGroups $groupssh" >> /etc/ssh/sshd_config
echo "enter the users you want to make keys for (separated by just a space after the comma!)"
read -a users

usersLength=${#users[@]}	

for (( i=0;i<$usersLength;i++))
do
  usermod -aG $addgroupssh ${users[${i}]}
  mkdir /home/${users[${i}]}/.ssh/
  touch /home/${users[${i}]}/.ssh/authorized_keys
  echo "please enter the directory as /home/${users[${i}]}/.ssh/authorized_keys when prompted"
  sleep 2
  ssh-keygen -t rsa
  chmod 600 /home/${users[${i}]}/.ssh/authorized_keys
done
  
  
