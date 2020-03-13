=b
This script helps to build the passwordless ssh longin to each node by all users. Developed by Prof. Shin-Pon Ju at NSYSY
2020/01/05
=cut

use Expect;  
use Parallel::ForkManager;
use MCE::Shared;

$forkNo = 30;
$ENV{TERM} = "vt100";
my $pm = Parallel::ForkManager->new("$forkNo");

@user=('jsp');
%passwd;
$passwd{jsp} = "j0409lee";

@avaIP;# all available IPs
for (2..30){
	$temp = "192.168.0.$_";
	system("ping -c 1 $temp");
		if($? eq 0){
		   print  "** $? $temp\n";# for the following Perl scripts
     		push (@avaIP , $temp);
		}
		else{
			goto CONT;	
		}
}
CONT:

    print "************test Begin\n";

for (@user){
	$pm->start and next;
	my $exp = Expect->new;
	$exp = Expect->spawn("su $_ \n");
	$exp->expect(2,[
						qr/password:/i,
						sub {
								my $self = shift ;
								$self->send("$passwd{$_}\n");      
							}
					]);		
	$exp -> send("rm -rf /home/$_/\.ssh\n") if ($exp->expect(2,'$'));
   	$exp -> send("mkdir  /home/$_/\.ssh\n") if ($exp->expect(2,'$'));
    $exp -> send("chmod 700 /home/$_/\.ssh\n") if ($exp->expect(2,'$'));# give root the permission to generate ssh key
    $exp -> send("ssh-keygen -t rsa \n") if ($exp->expect(2,'$'));
    $exp -> send("\n") if ($exp->expect(2,'Enter'));
    $exp -> send("\n") if ($exp->expect(2,'Enter'));
    $exp -> send("\n") if ($exp->expect(2,'Enter'));   
    $exp -> send("cd /home/$_/\.ssh\n") if ($exp->expect(2,'$'));
    $exp -> send("cp id_rsa.pub authorized_keys\n") if ($exp->expect(2,'$'));
    $exp -> send("chmod 640 /home/$_/\.ssh/authorized_keys\n") if ($exp->expect(2,'$'));
	$exp -> send("exit\n") if ($exp->expect(2,'$'));
	$exp->soft_close();
$pm->finish;
}
$pm->wait_all_children;
    
    print "************test\n";
#system("/etc/init.d/sshd restart");
# ssh nodeXX is paswdless after the above process.

######### go through each IP for the final passworless setting
#
for $userName (@user){
	$pm->start and next;
    my $exp = Expect->new;
   	$exp = Expect->spawn("su $userName");

 for $IP (@avaIP){	
	 print "IP $IP\n";
	$exp ->send("ssh $IP \n") if ($exp->expect(2,'$'));;
	$exp->expect(2,[
						qr/password:/i,
						sub {
								my $self = shift ;
								$self->send("$passwd{$userName}\n");                            
								exp_continue;
							}
					],
					[
						qr/connecting \(yes\/no\)/i,
						sub {
								my $self = shift ;
								$self->send("yes\n");	#first time to ssh into this node				        
								#Are you sure you want to continue connecting (yes/no)?
							}
					]
		); 
				$exp->expect(2,[
						qr/password:/i,
						sub {
								my $self = shift ;
								$self->send("$passwd{$userName}\n");      
							}
					]);	
	$exp -> send("\n") if ($exp->expect(2,'$'));
	$exp -> send("exit\n") if ($exp->expect(2,'$'));
	}# end of IP loop
$exp->soft_close();
$pm->finish;
#
}#end of username loop
$pm->wait_all_children;


for $userName (@user){
	$pm->start and next;
    my $exp = Expect->new;
   	$exp = Expect->spawn("su $userName");

 for (0..$#avaIP){	
	$temp=$_+1;
    $nodeindex=sprintf("%02d",$temp);
    $nodename= "node"."$nodeindex";
    print "\n**nodename**:$nodename\n"; 
	$exp ->send("ssh $nodename \n") if ($exp->expect(2,'$'));;
	$exp->expect(2,[
						qr/password:/i,
						sub {
								my $self = shift ;
								$self->send("$passwd{$userName}\n");                            
								exp_continue;
							}
					],
					[
						qr/connecting \(yes\/no\)/i,
						sub {
								my $self = shift ;
								$self->send("yes\n");	#first time to ssh into this node				        
								#Are you sure you want to continue connecting (yes/no)?
							}
					]
		); 
				$exp->expect(2,[
						qr/password:/i,
						sub {
								my $self = shift ;
								$self->send("$passwd{$userName}\n");      
							}
					]);	
	$exp -> send("\n") if ($exp->expect(2,'$'));
	$exp -> send("exit\n") if ($exp->expect(2,'$'));
	}# end of IP loop
$exp->soft_close();
$pm->finish;
#
}#end of username loop
$pm->wait_all_children;


print "\n\n***###00settingUser_rsa.pl: root passwordless setting done******\n\n";
#
