#this script can be used for reconfigure for slurm
use Expect;
use Parallel::ForkManager;
use MCE::Shared;

@partition = (
'PartitionName=debug Nodes=node01 Default=YES MaxTime=INFINITE State=UP',
'PartitionName=AMD Nodes=node02 Default=NO MaxTime=INFINITE State=UP'
);

$forkNo = 30;
my $pm = Parallel::ForkManager->new("$forkNo");

open ss,"<./IP_coreNo.txt";
@input = <ss>;
close(ss);

%coreNo;
%socketNo;
%threadNo;
%coresocketNo;

for (@input){
	$_ =~s/^\s+//g;#replace operation 
	@temp = split(/\s+/,$_);
	chomp $temp[0];
	chomp $temp[1];
	chomp $temp[2];
	chomp $temp[3];
	chomp $temp[4];
	$coreNo{$temp[0]}=$temp[1];
	$socketNo{$temp[0]}=$temp[2];
	$threadcoreNo{$temp[0]}=$temp[3];
	$coresocketNo{$temp[0]}=$temp[4];
	print " IP and CoreNo: $temp[0]  $coreNo{$temp[0]} \n";
	print " IP and SocketNo: $temp[0]  $socketNo{$temp[0]} \n";
	print " IP and Thread perl Core: $temp[0]  $threadcoreNo{$temp[0]} \n";
	print " IP and Core perl Socket: $temp[0]  $coresocketNo{$temp[0]} \n";
}

$ENV{TERM} = "vt100";
$pass = "123"; ##For all roots of nodes

#### end of debug
# COMPUTE NODES
unlink "./slurm.conf";
system("cp slurmConf_template.txt slurm.conf");# cp from template file

for (sort keys %coreNo){
    $_ =~/192.168.0.(\d{1,2})/;
	$nodeID = $1 - 1;# node ID according to th fourth number of current IP
	chomp($nodeID);
    $formatted_nodeID = sprintf("%02d",$nodeID);
    $Nodename="node"."$formatted_nodeID";
   `echo "NodeName=$Nodename NodeAddr=$_ CPUs=$coreNo{$_} ThreadsPerCore=$threadcoreNo{$_} CoresPerSocket=$coresocketNo{$_}  State=UNKNOWN" >> ./slurm.conf`;#append the data into the file
#Sockets=1 CoresPerSocket=12 ThreadsPerCore=2
}

for (@partition){
		`echo "$_" >> ./slurm.conf`;
}

unlink "/etc/slurm/slurm.conf";
`cp ./slurm.conf /etc/slurm/`;

# The follwoing is for slurm setting
for (sort keys %coreNo){
	$pm->start and next;
    $_ =~/192.168.0.(\d{1,2})/;
	$nodeID = $1 - 1;# node ID according to th fourth number of current IP
	chomp($nodeID);
    $formatted_nodeID = sprintf("%02d",$nodeID);
    $Nodename="node"."$formatted_nodeID";
	$exp = Expect->new;
	$exp = Expect->spawn("scp  /etc/slurm/slurm.conf root\@$Nodename:/etc/slurm/slurm.conf \n");	
    $exp->soft_close();
	$pm->finish;
}# for loop
$pm->wait_all_children;

### Server setting
`rm -rf /var/spool/slurmctld`;
`mkdir /var/spool/slurmctld`;
`chown slurm: /var/spool/slurmctld`;
`chmod 755 /var/spool/slurmctld`;
`touch /var/log/slurmctld.log`;
`chown slurm: /var/log/slurmctld.log`;
`touch /var/log/slurm_jobacct.log /var/log/slurm_jobcomp.log`;
`chown slurm: /var/log/slurm_jobacct.log /var/log/slurm_jobcomp.log`;

######## start and enable munge  for each node
for (sort keys %coreNo){
	$pm->start and next;
    $_ =~/192.168.0.(\d{1,2})/;
	$nodeID = $1 - 1;# node ID according to th fourth number of current IP
	chomp($nodeID);
    $formatted_nodeID = sprintf("%02d",$nodeID);
    $Nodename="node"."$formatted_nodeID";
	my $exp = Expect->new;
	$exp = Expect->spawn("ssh $Nodename \n");
	$exp -> send("rm -rf /var/spool/slurmd \n") if ($exp->expect(2,'#'));
	$exp -> send("mkdir /var/spool/slurmd \n") if ($exp->expect(2,'#'));
	$exp -> send("chown slurm: /var/spool/slurmd \n") if ($exp->expect(2,'#'));
	$exp -> send("chmod 755 /var/spool/slurmd \n") if ($exp->expect(2,'#'));
	$exp -> send("rm -f /var/log/slurmd.log \n") if ($exp->expect(2,'#'));
	$exp -> send("touch /var/log/slurmd.log \n") if ($exp->expect(2,'#'));
	$exp -> send("chown slurm: /var/log/slurmd.log \n") if ($exp->expect(2,'#'));
	$exp -> send("systemctl stop firewalld\n") if ($exp->expect(2,'#'));
	$exp -> send("systemctl disable firewalld\n") if ($exp->expect(2,'#'));
	$exp -> send("slurmd -C \n") if ($exp->expect(2,'#'));
	$exp -> send("systemctl enable slurmd.service \n") if ($exp->expect(2,'#'));
	$exp -> send("systemctl start slurmd.service \n") if ($exp->expect(2,'#'));
	$exp -> send("systemctl status slurmd.service \n") if ($exp->expect(2,'#'));
	$exp -> send("exit\n") if ($exp->expect(2,'#'));
	$exp->soft_close();
	$pm->finish;
} # end of loop
$pm->wait_all_children;
### start slurm for server
`systemctl enable slurmctld.service`;
`systemctl start slurmctld.service`;
`systemctl status slurmctld.service`;

print "***** WATCH OUT!!!!!\n";
print "***** Begin slurmd check node by node!!!!!\n\n";
sleep(3);

#for (0..$#avaIP){	
for (sort keys %coreNo){
    $_ =~/192.168.0.(\d{1,2})/;
	$nodeID = $1 - 1;# node ID according to th fourth number of current IP
	chomp($nodeID);
    $formatted_nodeID = sprintf("%02d",$nodeID);
    $Nodename="node"."$formatted_nodeID";
    print "**Nodename**:$Nodename\n";
	system("slurmd -C");
	print "\n\n";
	#$pm->finish;
}# for loop

#To display the compute nodes: scontrol show nodes
#To display the job queue: scontrol show jobs
#To submit script jobs: sbatch -N2 script-file
