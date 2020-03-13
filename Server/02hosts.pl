## make your cluster DNS
## check /etc/hosts first 
$nodeNo=20; ####The total slave nodes you want to install, you may use more number than the nodes you have
`echo 127.0.0.1    localhost > /etc/hosts`;
`echo ::1     localhost ip6-localhost ip6-loopback >> /etc/hosts`;
`echo ff02::1 ip6-allnodes >> /etc/hosts`;
`echo ff02::2 ip6-allrouters >> /etc/hosts`;
`echo 192.168.0.1 master >> /etc/hosts`;

foreach (1..$nodeNo){
$temp=$_+1;
$nodeindex=sprintf("%02d",$_);
$nodename= "192.168.0."."$temp"." "."node"."$nodeindex";
`echo $nodename >> /etc/hosts`;
}
print "\n\n***###02hosts.pl: set hostnames for all nodes done******\n\n";
