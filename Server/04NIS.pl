## You Need install ypbind yp-tools ypserv rpcbind first
## yum -y install ypbind yp-tools ypserv rpcbind 

`ypdomainname melcluster`;
`nisdomainname melcluster`;
`echo "NISDOMAIN=melcluster" > /etc/sysconfig/network`;
`echo "255.255.255.0    192.168.0.0" > /var/yp/securenets`;
`echo "domain melcluster server master" > /etc/yp.conf`;
system("systemctl start  ypbind ypserv ypxfrd yppasswdd");
system("systemctl enable  ypbind ypserv ypxfrd yppasswdd");
#chdir("/var/yp");
#`make`;# make new database

`echo -e "\004" | /usr/lib64/yp/ypinit -m`;
system("systemctl restart  ypbind ypserv ypxfrd yppasswdd");
print "\n\n***###04NIS.pl: set NIS done******\n\n";

