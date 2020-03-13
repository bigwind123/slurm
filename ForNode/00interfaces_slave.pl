=start_form
use vi to modify the ifcfg- file in /etc/sysconfig/network-scripts/$NetCard
1.
BOOTPROTO=static <---
ONBOOT=yes  <---
IPADDR=192.168.0.1  <--- set IP here and then we can use scp from server to do all settings
2.
then ifup XXXX
=cut
$domainname= "melcluster";

#get internet card name
@temp =`ip a`;

foreach (@temp){
	if($_ =~/2:\s+(e.+):\s+/){#: must be used, otherwise you will find two 
		$Nic_inner = $1;# matched internet card name
	}
    if($_ =~/192.168.0.(\d{1,2})\/24/){#192.168.0.X/24
		$fourth_ipnum = $1;
		$nodeID = $1 - 1;# node ID according to th fourth number of current IP
	}
}

`domainname $domainname`;# give domainname of your cluster

# do the initial configuring for NIC cards.
@dev= ("$Nic_inner"); #### Maybe you can use Perl to get these.

#Net card Number
@NetCard = ();
$FullCardN = 0;
foreach (@dev){ #enp0s3 -> ifcfg-enp0s3
  $FullCardN = "ifcfg-"."$_";
  push(@NetCard, $FullCardN);
}

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

chomp($nodeID);
$formatted_nodeID = sprintf("%02d",$nodeID);
$hostname="node"."$formatted_nodeID";
`echo $hostname > /etc/hostname`;
`hostname $hostname`;
`hostnamectl set-hostname $hostname`;

#inner net setting
`echo "BOOTPROTO=static" > /etc/sysconfig/network-scripts/$NetCard[0]`;
`echo "DEVICE=$dev[0]" >> /etc/sysconfig/network-scripts/$NetCard[0]`;
`echo "NAME=$dev[0]" >> /etc/sysconfig/network-scripts/$NetCard[0]`;
`echo "ONBOOT=yes" >> /etc/sysconfig/network-scripts/$NetCard[0]`;
`echo "IPADDR=192.168.0.$fourth_ipnum" >> /etc/sysconfig/network-scripts/$NetCard[0]`;
`echo "NETMASK=255.255.255.0" >> /etc/sysconfig/network-scripts/$NetCard[0]`;
`echo "GATEWAY=192.168.0.1" >> /etc/sysconfig/network-scripts/$NetCard[0]`;
`echo "DNS1=8.8.8.8" >> /etc/sysconfig/network-scripts/$NetCard[0]`;
`echo "DNS2=140.117.11.1" >> /etc/sysconfig/network-scripts/$NetCard[0]`;
`echo "BROADCAST=192.168.0.255" >> /etc/sysconfig/network-scripts/$NetCard[0]`;
`echo "UUID=$nmcli{$dev[0]}" >> /etc/sysconfig/network-scripts/$NetCard[0]`;
`echo "HWADDR=$mac{$dev[0]}" >> /etc/sysconfig/network-scripts/$NetCard[0]`; 
`echo "TYPE=Ethernet" >> /etc/sysconfig/network-scripts/$NetCard[0]`;

foreach (@dev){
  system("ifup $_");## configure the NIC
  system("ip addr flush dev $_");## remove all previous setting (because we want to assign new informatio)  
  system("ifdown $_ ");## stop this NIC and force it to use new seeting by the following command 
  system("ifup $_"); ## use new setting
}
system('/etc/init.d/network restart');
system("killall -9 yum");
system("yum install ntp -y");
system("timedatectl set-timezone Asia/Taipei");## setting timezone
system("systemctl stop ntpd ");
system("ntpdate pool.ntp.org");
system("systemctl start ntpd ");
system("systemctl enable ntpd");

#system("service networking restart");## restart the network by new setting
#`systemctl restart network`;
#sleep(2);

