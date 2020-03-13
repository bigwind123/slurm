## make your cluster DNS
## check /etc/hosts first 
#require "./BaseSetting_node.pl";

$nodeNo=20; ##### the total slave node Number you want to install 

@temp =`ip a`;

foreach (@temp){
	if($_ =~/192.168.0.(\d{1,2})\/24/){#192.168.0.X/24
		$fourth_ipnum = $1;
		$ID = $1 - 1;# node ID according to th fourth number of current IP
	}
}

$nodeID=sprintf("%02d",$ID);
$current_nodeID="node"."$nodeID";

`echo 127.0.0.1    localhost > /etc/hosts`;
#`echo 127.0.1.1    $current_nodeID >> /etc/hosts`;
`echo ::1     localhost ip6-localhost ip6-loopback >> /etc/hosts`;
`echo ff02::1 ip6-allnodes >> /etc/hosts`;
`echo ff02::2 ip6-allrouters >> /etc/hosts`;
`echo 192.168.0.1    master >> /etc/hosts`;

foreach (1..$nodeNo){
$temp=$_+1;
$nodeindex=sprintf("%02d",$_);
$nodename= "192.168.0."."$temp"." "."node"."$nodeindex";
`echo $nodename >> /etc/hosts`;
}
