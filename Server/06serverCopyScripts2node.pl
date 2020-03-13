=beg
This Perl script uses the Expect module to scp all required Perl scripts from server to each node after you assign the private IP
for all nodes. We put all scripts in the directory "ForNode".-- developed by Prof. Shin-Pon Ju at NSYSU (11/28/2019)
=cut
#!/usr/bin/perl
use Expect;
use Parallel::ForkManager;

$forkNo = 30;
$ENV{TERM} = "vt100";
$pass = "123"; ##For all roots of nodes
open ss,"<./Nodes_IP.txt";
@avaIP=<ss>;# all available IPs
close(ss);

#for(@avaIP){print;}
#for(@avaIP){
my $pm = Parallel::ForkManager->new("$forkNo");

for (0..$#avaIP){	
	$pm->start and next;
	$temp=$_+1;
    $nodeindex=sprintf("%02d",$temp);
    $nodename= "node"."$nodeindex";
    print "**nodename**:$nodename\n";
    system("ssh $nodename \'rm -f /root/*.pl\'");
    system("scp  /root/ForNode/* root\@$nodename:/root");
    system("ssh $nodename \'rm -f nohup.out\'");
    #system("ssh $nodename \'nohup perl oneclick_slave.pl &\'");
    $exp = Expect->new;
	$exp = Expect->spawn("ssh $nodename");
	$exp->send ("nohup perl oneclick_slave.pl & \n") if ($exp->expect(2,'#'));# nohup perl can't be done by ssh nodeXX ''
	$exp -> send("exit\n") if ($exp->expect(2,'#'));
	$exp->soft_close();
    $pm-> finish;
}# for loop
$pm->wait_all_children;

######## begin executabe all Perl scripts in each node
#for (@avaIP){	
#	$pm->start and next;
#	my $exp = Expect->new;
#	$exp = Expect->spawn("ssh -l root $_ \n");
#	$exp->send ("rm -f nohup.out\n") if ($exp->expect(2,'#'));
#	$exp->send ("nohup perl oneclick_slave.pl & \n") if ($exp->expect(2,'#'));
#	$exp -> send("exit\n") if ($exp->expect(2,'#'));
#	$exp->soft_close();
#    $pm->finish;
#} # end of loop
#$pm->wait_all_children;
print "\n\n***###06serverCopyScripts2node.pl: Copy scripts to each node done******\n\n";
