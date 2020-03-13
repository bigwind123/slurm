@node_array = ("00interfaces_slave.pl","01packages_slave.pl"
			   ,"02hosts_slave.pl","03NFS_slave.pl"
			   ,"04NIS_slave.pl");#,"05munge_slave.pl");#,"05TORQUE_node.pl");
foreach(@node_array){
	system("perl $_");
	sleep(1);
}


@temp =`ip a`;

foreach (@temp){	
    if($_ =~/192.168.0.(\d{1,2})\/24/){#192.168.0.X/24
		$fourth_ipnum = $1;
		$nodeID = $1 - 1;# node ID according to th fourth number of current IP
	}
}

$formatted_nodeID = sprintf("%02d",$nodeID);
$hostname="node"."$formatted_nodeID";
unlink "/home/$hostname".".txt"; 
sleep(1);
open Check, "> /home/$hostname".".txt"; #You may check the NFS workable or not at the same time

#print Check "n/n===========\n";
print Check "****NFS test\n";
$temp = `df -hT`;
print Check "$temp\n";
print Check "\n\n *** If you see master:/home and master:/opt, NFS works for this slave node.\n";
print Check "========****End of NFS test\n\n";

print Check "\n\n===============================\n";
print Check "****NIS test\n";
$temp = `yptest`;
print Check "$temp\n";
print  Check "\n\nIf you see the 9 test results, the nis setting is ok\n";
print  Check "========****End of NIS test\n\n";

#print Check "\n\n===============================\n";
#print Check "****munge check (cd /etc/munge) \n";
#
#$mungecheck = `cd /etc/munge`;
#print Check "****munge check (cd /etc/munge) results: $mungecheck\n";

####date check

print Check "\n\n***** date check******\n";
$temp = `date`;
print Check "****date check: $temp\n";
close(Check);
