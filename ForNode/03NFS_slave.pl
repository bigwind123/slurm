## make NFS client (slave node)
#system ("mkdir /work");
print "\n\n**** NFS setting\n";
system("umount master:/home"); # umount the nfs of master first
system("umount master:/opt"); # umount the nfs of master first

if(!`grep 'master:/home /home nfs4 _netdev,auto 0 0' /etc/fstab`){
	`echo master:/home /home nfs4 _netdev,auto 0 0 >> /etc/fstab`;
}
if(!`grep 'master:/opt /opt nfs4 _netdev,auto 0 0' /etc/fstab`){
	`echo master:/opt /opt nfs4 _netdev,auto 0 0 >> /etc/fstab`;
}

if(!`grep 'mount -a' /etc/rc.local`){
	`echo mount -a >> /etc/rc.local`;
}

system("mount -a");
