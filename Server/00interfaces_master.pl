#CentOS 7 one click to set up Server
########## Things to know first 
#1. You need to check the internet card name before installation (ls /etc/sysconfig/network-scripts|grep ifcfg-*)
#ifup ifcfg-enp0s3 (if the internet card cfg file is ifcfg-enp0s3)
#yum -y install net-tools
##****** perl -v to make sure Perl has been installed!!!!!!!!!!!!
#2. try ip addr


## basic setting
require "./BaseSetting_ser.pl"; # server setting for real machine or virtualbox
`domainname $domainname`;
`hostname master`;
`echo master > /etc/hostname`;
`hostnamectl set-hostname master`;# setm permanent hostname 
`echo "$domainname" > /etc/sysconfig/network`;
`nisdomainname $domainname`;

# do the initial configuring for NIC cards.
@dev= ("$Nic_internet", "$Nic_inner"); #### Maybe you can use Perl to get these.

#Net card Number
@NetCard = ();
$FullCardN = 0;
#internet config file name
foreach (@dev){ #enp0s3 -> ifcfg-enp0s3
  $FullCardN = "ifcfg-"."$_";
  push(@NetCard, $FullCardN);
}

#network setting
#path = /etc/sysconfig/network-scripts/ifcfg-enp0s3(ifcfg-enp0s3 is your net cards);

### get UUID for each internetcard
@nmcli = `nmcli con show`;
%nmcli;
foreach $nmid (1..$#nmcli){# element 0 includes the header of nmcli 
      chomp $nmcli[$nmid];
      @temp = split(/\s+/,$nmcli[$nmid]);
      $nmcli{$temp[0]}=$temp[1];
}

# get MAC of each internet card
%mac;
foreach (@dev){
      $ipne = `ip add show $_`;      
      $ipne =~ /(\w+:\w+:\w+:\w+:\w+:\w+)/;# the first matched item is mac!
      $mac{$_}="$1";      
}

#internet setting
if($machine ne "virtualbox"){
`echo "BOOTPROTO=static" > /etc/sysconfig/network-scripts/$NetCard[0]`;#open a new file
`echo "DNS1=$dns_nameservers1" >> /etc/sysconfig/network-scripts/$NetCard[0]`;
`echo "DNS2=$dns_nameservers2" >> /etc/sysconfig/network-scripts/$NetCard[0]`;
`echo "GATEWAY=$gateway" >> /etc/sysconfig/network-scripts/$NetCard[0]`;
}
else{
`echo "BOOTPROTO=dhcp" > /etc/sysconfig/network-scripts/$NetCard[0]`;
}

`echo "DEVICE=$dev[0]" >> /etc/sysconfig/network-scripts/$NetCard[0]`;#append the data into the file
`echo "NAME=$dev[0]" >> /etc/sysconfig/network-scripts/$NetCard[0]`;
`echo "ONBOOT=yes" >> /etc/sysconfig/network-scripts/$NetCard[0]`;
`echo "IPADDR=$address" >> /etc/sysconfig/network-scripts/$NetCard[0]`;
`echo "NETMASK=$netmask" >> /etc/sysconfig/network-scripts/$NetCard[0]`;
`echo "UUID=$nmcli{$dev[0]}" >> /etc/sysconfig/network-scripts/$NetCard[0]`;
`echo "HWADDR=$mac{$dev[0]}" >> /etc/sysconfig/network-scripts/$NetCard[0]`; 
`echo "DEFROUTE=yes" >> /etc/sysconfig/network-scripts/$NetCard[0]`;
`echo "TYPE=Ethernet" >> /etc/sysconfig/network-scripts/$NetCard[0]`;

#inner net setting
`echo "BOOTPROTO=static" > /etc/sysconfig/network-scripts/$NetCard[1]`;
`echo "DEVICE=$dev[1]" >> /etc/sysconfig/network-scripts/$NetCard[1]`;
`echo "NAME=$dev[1]" >> /etc/sysconfig/network-scripts/$NetCard[1]`;
`echo "ONBOOT=yes" >> /etc/sysconfig/network-scripts/$NetCard[1]`;
`echo "IPADDR=192.168.0.1" >> /etc/sysconfig/network-scripts/$NetCard[1]`;
`echo "NETMASK=255.255.255.0" >> /etc/sysconfig/network-scripts/$NetCard[1]`;
`echo "BROADCAST=192.168.0.255" >> /etc/sysconfig/network-scripts/$NetCard[1]`;
`echo "UUID=$nmcli{$dev[1]}" >> /etc/sysconfig/network-scripts/$NetCard[1]`;
`echo "HWADDR=$mac{$dev[1]}" >> /etc/sysconfig/network-scripts/$NetCard[1]`; 
`echo "TYPE=Ethernet" >> /etc/sysconfig/network-scripts/$NetCard[1]`;

#restart networking
foreach (@dev){
  system("ifup $_");## configure the NIC
  system("ip addr flush dev $_");## remove all previous setting (because we want to assign new informatio)  
  system("ifdown $_ ");## stop this NIC and force it to use new seeting by the following command 
  system("ifup $_"); ## use new setting
 }

#system('/etc/init.d/network restart');
#system("service network restart");
system("systemctl restart network");

### The following packages are for CentOS 7
system("killall -9 yum");
system("rm -rf /var/run/yum.pid");
system('yum -y groupinstall "Development Tools"');

@package = ("vim", "wget", "net-tools", "epel-release", "htop", "make"
			, "openssh*", "nfs-utils", "ypserv" ,"yp-tools","geany","psmisc"
			,  "iptables-services", "ypbind" , "rpcbind","perl-Expect","ntp"
			, "nfs-utils","perl-MCE-Shared","perl-Parallel-ForkManager");
foreach(@package){
	system("yum -y install $_");
}

system("yum -y upgrade");

system("timedatectl set-timezone Asia/Taipei");## setting timezone
system("systemctl stop ntpd ");
system("ntpdate pool.ntp.org");
system("systemctl start ntpd ");
system("systemctl enable ntpd");
print "\n\n***###00interfaces_master.pl: set internet card done******\n\n";


