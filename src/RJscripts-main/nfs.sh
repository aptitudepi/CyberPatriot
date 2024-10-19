sudo ufw enable
sudo apt install nfs-common -y
sudo apt install nfs-kernel-server -y 
echo "Enter NFS directory:"
read nfsdirectory
sudo chown nobody:nogroup $nfsdirectory
ip address
echo "input IP w/ subnet"
read nfsIP
echo "$nfsdirectory     $nfsIP(ro,sync,no_subtree_check,no_root_squash)" > /etc/exports
#echo "you might want to allow your IP address instead of * in /etc/exports" > ~/nfsthingtodo.txt
sudo exportfs -a
sudo mount $nfsIP:$nfsdirectory $nfsdirectory

