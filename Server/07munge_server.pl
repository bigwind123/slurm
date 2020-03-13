#!/usr/bin/perl
#SLURM installation script developed by Prof. Shin-Pon Ju 2019/12/15

use Expect;
use Parallel::ForkManager;

$forkNo = 30;
my $pm = Parallel::ForkManager->new("$forkNo");

open ss,"<./Nodes_IP.txt"; #generate by 05root_rsa.pl
@avaIP=<ss>;# all available IPs
close(ss);


# find all IPs of available nodes 
$ENV{TERM} = "vt100";
$pass = "123"; ##For all roots of nodes
system("systemctl stop munge");
system("killall munged");

# Removing the old slurm setting
`yum remove mariadb-server mariadb-devel -y`;
sleep(1);
#Munge is an authentication tool used to identify messaging from the Slurm machines
`yum remove slurm munge munge-libs munge-devel -y`;
sleep(1);
if(`grep 'slurm' /etc/passwd`){#remove the old slurm account
	system("userdel -r slurm");
}

if(`grep 'munge' /etc/passwd`){#remove the old slurm account
	print "**Response from grep 'munge' /etc/passwd: True \n";
	$temp = `userdel -r munge`;
	print "**Response from userdel -r munge: $temp \n"; #empty is good
		if($temp=~/currently used by process (\d+)/){
			`kill $1`;
			`userdel -r munge`;
			}
}

### End of removing old munge setting

`yum install mariadb-server mariadb-devel -y`;
=b
Create the global users:
Slurm and Munge require consistent UID and GID across every node in the cluster.
=cut

#For all the nodes, before you install Slurm or Munge:
$MUNGEUSER=991;
`groupadd -g $MUNGEUSER munge`;
`useradd  -m -c "MUNGE Uid 'N' Gid Emporium" -d /var/lib/munge -u $MUNGEUSER -g munge  -s /sbin/nologin munge`;
$SLURMUSER=992;
`groupadd -g $SLURMUSER slurm`;
`useradd  -m -c "SLURM workload manager" -d /var/lib/slurm -u $SLURMUSER -g slurm  -s /bin/bash slurm`;

#install Munge for the server
system("rm -rf /etc/munge");
system("rm -rf  /var/log/munge");
system("rm -rf  /var/lib/munge");

system("yum install munge munge-libs munge-devel -y");
system("chown -R munge: /etc/munge/ /var/log/munge/");
system("chmod 0700 /etc/munge/ /var/log/munge/");
system("chmod 0711 /var/lib/munge/");# no this on https://www.slothparadise.com/how-to-install-slurm-on-centos-7-cluster/

unlink "/etc/munge/munge.key";
system("/usr/sbin/create-munge-key -r");
system("dd if=/dev/urandom bs=1 count=1024 > /etc/munge/munge.key");
system("chown munge: /etc/munge/munge.key");
system("chmod 400 /etc/munge/munge.key");
sleep(1);

for (0..$#avaIP){	
	$pm->start and next;
	$temp=$_+1;
    $nodeindex=sprintf("%02d",$temp);
    $nodename= "node"."$nodeindex";
    print "**nodename**:$nodename\n";    

    $exp = Expect->new;
	$exp = Expect->spawn("ssh $nodename\n");
	$exp->send ("rm -f nohup.out \n") if ($exp->expect(2,'#'));
	$exp->send ("nohup perl 05munge_slave.pl \n") if ($exp->expect(2,'#'));
	$exp -> send("exit\n") if ($exp->expect(2,'#'));
    $pm->finish;
}
$pm->wait_all_children;
sleep(1);

system("systemctl enable munge");
system("systemctl start munge");

print "\n\n ***** test munge by munge -n\n\n";
system("munge -n");
system("munge -n| unmunge");
system("remunge");

print "\n\n If everything ok, conduct \"07munge_server4slave.pl\"\n\n";
