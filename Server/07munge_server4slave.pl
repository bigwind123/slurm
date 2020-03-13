#!/usr/bin/perl
#munge setting for nodes developed by Prof. Shin-Pon Ju 2020/01/09

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

for (0..$#avaIP){	
	$pm->start and next;
	$temp=$_+1;
    $nodeindex=sprintf("%02d",$temp);
    $nodename= "node"."$nodeindex";
    print "**nodename**:$nodename\n";
    system("scp  /etc/munge/munge\.key root\@$nodename:/etc/munge/");
    system("ssh $nodename \'ls -al /etc/munge/\'"); 	
    $pm->finish;
} # end of loop
$pm->wait_all_children;

for (0..$#avaIP){	
	$pm->start and next;
	$temp=$_+1;
    $nodeindex=sprintf("%02d",$temp);
    $nodename= "node"."$nodeindex";
    print "**nodename**:$nodename\n"; 
	$exp = Expect->new;
	$exp = Expect->spawn("ssh $nodename\n");	
	$exp->send ("chown munge: /etc/munge/munge.key\n") if ($exp->expect(2,'#'));
	$exp->send ("chmod 400 /etc/munge/munge.key\n") if ($exp->expect(2,'#'));
	$exp->send ("systemctl enable munge\n") if ($exp->expect(2,'#'));
	$exp->send ("systemctl start munge\n") if ($exp->expect(2,'#'));
	$exp->send ("munge -n\n") if ($exp->expect(2,'#'));
	$exp->send ("munge -n| unmunge \n") if ($exp->expect(2,'#'));	
	$exp -> send("exit\n") if ($exp->expect(2,'#'));
    $pm->finish;
}
$pm->wait_all_children;
sleep(1);
print "***** WATCH OUT!!!!!\n";
print "***** Begin munge ssh decode check node by node!!!!!\n\n";
sleep(3);
for (0..$#avaIP){	
	#$pm->start and next;
	$temp=$_+1;
    $nodeindex=sprintf("%02d",$temp);
    $nodename= "node"."$nodeindex";
    print "**nodename**:$nodename\n";
	system("munge -n \| ssh $nodename unmunge");
	#$pm->finish;
}# for loop

