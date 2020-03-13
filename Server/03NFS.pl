#systemctl start rpcbind
#systemctl enable rpcbind
system("service nfs start");
############### NFS share Folder ###################
#system("mkdir /work");
`chmod -R 755 /home`;# or 700
`chmod -R 755 /opt`;

############### exports file setting ###################
#/home
`echo "/home 192.168.0.0/24(rw,no_root_squash,no_subtree_check,sync)" > /etc/exports`;
#/opt
`echo "/opt 192.168.0.0/24(rw,no_root_squash,no_subtree_check,sync)" >> /etc/exports`;

`systemctl enable rpcbind`;
`systemctl enable nfs-server`;
`systemctl enable nfs-lock`;
`systemctl enable nfs-idmap`;

`systemctl start rpcbind`;
`systemctl start nfs-server`;
`systemctl start nfs-lock`;
`systemctl start nfs-idmap`;

system("exportfs -r"); # make setting work!
print "\n\n***###03NFS.pl: set NFS done******\n\n";

# -v list all shared folders
#-a
########################## 
