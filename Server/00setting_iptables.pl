#!/usr/bin/perl -w
#***systemctl status iptables: check iptables service status
#***iptables -nLv: check the current iptables setting
#http://linux.vbird.org/linux_server/0250simple_firewall.php
#https://www.itread01.com/content/1500003489.html
#https://www.opencli.com/linux/iptables-command
# presetting 
# check https://linuxize.com/post/how-to-install-iptables-on-centos-7/
require "./BaseSetting_ser.pl"; # server setting for real machine or virtualbox

`systemctl stop firewalld`;#stop the FirewallD service
`systemctl disable firewalld`;#Disable the FirewallD service to start automatically on system boot
`systemctl mask --now firewalld`;#Mask the FirewallD service to prevent it from being started
#by another services
system("killall -9 yum");
#system("yum remove -y iptables-services");
system("yum install -y iptables-services");
system("systemctl start iptables");
system("systemctl enable iptables");#Enable the Iptables service to start automatically on system boot

# put all IPs allowed SSH login into @iparray
@iparray = qw(
140.117.55.92 
140.117.55.93 
111.185.232.59
140.117.55.175
140.117.56.51 
140.117.56.66 
140.117.56.67 
140.117.56.68 
140.117.56.69 
140.117.59.181
140.117.59.182
140.117.59.183
140.117.59.184
140.117.59.185
140.117.59.186
140.117.59.187
140.117.59.188
140.117.59.189
140.117.59.190
140.117.59.191
140.117.59.193
140.117.59.194
140.117.59.195
140.117.60.161
140.117.60.162
140.117.60.163
140.117.60.164
140.117.60.165
140.117.60.178
140.117.60.179
140.117.60.250
);

#$Nic_internet = "enp0s29u1u6";# internet card name with the public IP for POSTROUTING

# remove all defined rules first!
`iptables -F`;
`iptables -F -t nat`; 
`iptables -Z`;
`iptables -X`;

system ("iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -o $Nic_internet -j MASQUERADE");

#assign policies
`iptables -P INPUT ACCEPT`;
#`iptables -P  OUTPUT DROP`;
#`iptables -P FORWARD DROP`;
#system("iptables -A INPUT -s 192.168.0.100 -p tcp --dport 22 -j DROP");# For test
#system ("iptables -A INPUT -j DROP");# For test
foreach (@iparray){
	chomp $_;
	system ("iptables -A INPUT -s $_ -p tcp --dport 22 -j ACCEPT");
        #print "iptables -A INPUT -s $_  -p tcp --dport 22 -j ACCEPT\n";#$ip
	#print "iptables -A INPUT -s  -p tcp --dport 22 -j ACCEPT\n";	
}
system ("iptables -A INPUT -s 192.168.0.0/24 -p tcp --dport 22 -j ACCEPT");
system ("iptables -A INPUT -s 192.168.0.0/24 -p icmp -j ACCEPT");# for ping server
system ("iptables -A INPUT -p icmp -s 127.0.0.1 -j ACCEPT");

system ("iptables -A INPUT -p tcp --dport 22 -j DROP");

#` iptables -A INPUT -p icmp -s 192.168.0.0/24 --icmp-type echo-request -j ACCEPT`;# allow to use ping

`iptables-save >  /etc/sysconfig/iptables`; # save the current iptables setting for rebootting
