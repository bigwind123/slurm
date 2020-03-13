require "./BaseSetting_ser.pl";
`chmod +x /etc/rc.d/rc.local`; # let rc.local can start when reboot

######### The following ($rclocal) is the default content
`echo "#!/bin/bash" > /etc/rc.local`; 					#ori
`echo "touch /var/lock/subsys/local" >> /etc/rc.local`; #ori
`echo "sysctl net.ipv4.ip_forward=1" >> /etc/rc.local`; #share net for every node

system ("sysctl net.ipv4.ip_forward=1");
system ("source /etc/rc.local"); 
print "\n\n***###01rc_local.pl: set rc.local done******\n\n";
