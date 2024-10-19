sudo ssh-keygen
ip addr > ~/vmip.txt
dig +short myip.opendns.com @resolver1.opendns.com > ~/vmip2.txt
cat vmip2.txt
echo "enter the username of the main user"
read -a sshusername
echo "just run ssh -p 22 $sshusername@vmip"
