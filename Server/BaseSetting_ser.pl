## You need to make sure your internet card names first by ip a 

#$machine = "virtualbox";
$machine = "realmachine";
$domainname= "melcluster";

# You need to modify this for new cluster!!!
#$Nic_internet = "enp3s0"; #internet card, # nmcli con or ip add to show 
#$Nic_inner = "enp0s29u1u2"; 	  #inner_net card # nmcli con or ip add to show

$Nic_internet = "enp3s0"; #internet card, # nmcli con or ip add to show 
$Nic_inner = "enp4s0"; 	  #inner_net card # nmcli con or ip add to show

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

#$address= "140.117.59.190";# NAT for virtualbox(10.0.2.15, default IP, may be different)
#$netmask= "255.255.255.0";# NAT for virtualbox
#$gateway= "140.117.59.254";# !! You should assign this for the real cluster.
$address= "140.117.59.181";# NAT for virtualbox(10.0.2.15, default IP, may be different)
$netmask= "255.255.255.0";# NAT for virtualbox
$gateway= "140.117.55.254";# !! You should assign this for the real cluster. (VB does not use it)


##You need to check your local IP provider for the following DNS information. If not available, 1.1.1.1 and 8.8.8.8 could be used
$dns_nameservers1= "140.117.11.1"; 
$dns_nameservers2= "168.95.1.1"; 
