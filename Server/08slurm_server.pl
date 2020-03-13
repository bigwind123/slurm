#!/usr/bin/perl
#SLURM installation script developed by Prof. Shin-Pon Ju 2019/12/15
# You need to install munge for server and nodes first
use Expect;
use Parallel::ForkManager;
use MCE::Shared;

$forkNo = 30;
my $pm = Parallel::ForkManager->new("$forkNo");
## get available IPs by reading or find them by ssh

open ss,"<./Nodes_IP.txt"; #generate by 05root_rsa.pl
chomp (@avaIP=<ss>);# all available IPs
close(ss);



#


#install Slurms

#$currentVer = "slurm-19.05.4.tar.bz2";#***** the latest version of this package (check the latest one if possible)
#$URL = "https://download.schedmd.com/slurm/$currentVer";#url to download
#$Dir4download = "slurm_download"; #the directory we download Mpich
#
#system ("rm -rf /home/$Dir4download");# remove the older directory first
#system("mkdir /home/$Dir4download");# make a new directory for NFS (because the package is needed for each node)
#@slurm_pack = qw(openssl openssl-devel pam-devel numactl numactl-devel hwloc hwloc-devel lua lua-devel readline-devel 
#rrdtool-devel ncurses-devel fribidi man2html libibmad libibumad);
#
#for (@slurm_pack){
#	system("yum install $_  -y");
#    sleep(1);
#}
#system ("yum upgrade");
#
#chdir("/home/$Dir4download");
#system("wget  $URL");
#system("yum install rpm-build -y");
#system("rpmbuild -ta $currentVer");
#
#system ("rm -rf /home/slurm_rpms");# remove the older directory first
#system("mkdir /home/slurm_rpms");# make a new directory for NFS (because the package is needed for each node)
#
#system("cp /root/rpmbuild/RPMS/x86_64/slurm-*  /home/slurm_rpms/");
#chdir("/home/slurm_rpms");
#system("yum --nogpgcheck localinstall slurm-* -y");
#
$ENV{TERM} = "vt100";
$pass = "123"; ##For all roots of nodes

######## begin install slurm in each node (need fork in the future)
for (@avaIP){	
	$pm->start and next;
	my $exp = Expect->new;
	$exp = Expect->spawn("ssh -l root $_ \n");
	$exp->send ("cd /home/slurm_rpms\n") if ($exp->expect(3,'#'));
	$exp -> send("yum --nogpgcheck localinstall slurm-* -y\n") if ($exp->expect(3,'#'));
	$exp -> send("\n") if ($exp->expect(3,'#'));
	$exp -> send("exit\n") if ($exp->expect(2,'#'));
	$exp->soft_close();
	$pm->finish;
} # end of loop
$pm->wait_all_children;

#configure slurm
tie my %coreNo, 'MCE::Shared';
tie my %socketNo, 'MCE::Shared';
tie my %threadcoreNo, 'MCE::Shared';
tie my %coresocketNo, 'MCE::Shared';

#%coreNo;
for (@avaIP){	
	$pm->start and next;
	my $exp = Expect->new;
	$exp = Expect->spawn("ssh -l root $_ \n");	
	
# get CPU Number	
	$exp->send ("lscpu|grep \"^CPU(s):\" | sed 's/^CPU(s): *//g' \n") if ($exp->expect(3,'#'));
	$exp->expect(2,'-re','\d+');#before() keeps command, match() keeps number, after() keep left part+root@master#
	$Mread = $exp->match();
	chomp $Mread;
    if ($Mread){
	  $coreNo{$_} = $Mread;
	  print "coreNo hash array $_ , Mread: $Mread, $coreNo{$_}\n";
	  };
	  
# get socket Number	
	$exp->send ("lscpu|grep \"^Socket(s):\" | sed 's/^Socket(s): *//g' \n") if ($exp->expect(3,'#'));
	$exp->expect(2,'-re','\d+');#before() keeps command, match() keeps number, after() keep left part+root@master#
	$Mread = $exp->match();
	chomp $Mread;
    if ($Mread){
	  $socketNo{$_} = $Mread;
	  print "socketNo hash array $_ , Mread: $Mread, $socketNo{$_}\n";
	  };
 # get the thread Number per core 	
	$exp->send ("lscpu|grep \"^Thread(s) per core:\" | sed 's/^Thread(s) per core: *//g' \n") if ($exp->expect(3,'#'));
	$exp->expect(2,'-re','\d+');#before() keeps command, match() keeps number, after() keep left part+root@master#
	$Mread = $exp->match();
	chomp $Mread;
    if ($Mread){
	  $threadcoreNo{$_} = $Mread;
	  print "threadcoreNo hash array $_ , Mread: $Mread, $threadcoreNo{$_}\n";
	  };

# get the core Number per socket 	
	$exp->send ("lscpu|grep \"^Core(s) per socket:\" | sed 's/^Core(s) per socket: *//g' \n") if ($exp->expect(3,'#'));
	$exp->expect(2,'-re','\d+');#before() keeps command, match() keeps number, after() keep left part+root@master#
	$Mread = $exp->match();
	chomp $Mread;
    if ($Mread){
	  $coresocketNo{$_} = $Mread;
	  print "coresocketNo hash array $_ , Mread: $Mread, $coresocketNo{$_}\n";
	  };

	$exp -> send("exit\n") if ($exp->expect(2,'#'));
	$exp->soft_close();
	$pm->finish;
} # end of loop
$pm->wait_all_children;
unlink("./IP_coreNo.txt");
open ss,">./IP_coreNo.txt";

for (sort keys %coreNo){
print ss "$_  $coreNo{$_} $socketNo{$_} $threadcoreNo{$_} $coresocketNo{$_}\n";
print  "$_  $coreNo{$_} $socketNo{$_} $threadcoreNo{$_} $coresocketNo{$_}\n";
}
close(ss);

print "\n\n*********slurm installation done! You need to configure slurm now!!\n";
