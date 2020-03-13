=b
This script helps to build the passwordless ssh longin to each node by root account. Developed by Prof. Shin-Pon Ju at NSYSY
2019/12/30

Nodes_IP.txt shows all node IPs. 
=cut

use Expect;  
use Parallel::ForkManager;
use MCE::Shared;

$forkNo = 30;
$ENV{TERM} = "vt100";
$pass = "123"; ##For all roots of nodes

unlink("./Nodes_IP.txt");
open ss,">./Nodes_IP.txt";
@avaIP;# all available IPs
for (2..30){
	$temp = "192.168.0.$_";
	system("ping -c 1 $temp");
		if($? eq 0){
		   print  "** $? $temp\n";# for the following Perl scripts

			print ss "$temp\n";# for the following Perl scripts
			push (@avaIP , $temp);
		}
		else{
			goto CONT;	
		}
}
CONT:
close(ss);
system("rm -f /root/\.ssh/*");# remove unexpect thing first
chdir("/root/.ssh");
system("ssh-keygen -t rsa -N \"\" -f id_rsa");
system("cp id_rsa.pub authorized_keys");
system("chmod 700 /root/\.ssh");
system("chmod 640 /root/\.ssh/authorized_keys");
system("/etc/init.d/sshd restart");
#### make .ssh directory of each node
#$quality = MCE::Shared->array;
my $pm = Parallel::ForkManager->new("$forkNo");
for (@avaIP){	
$pm->start and next;
	my $exp = Expect->new;
	$exp = Expect->spawn("ssh -l root $_ \n");
	$exp->expect(2,[
						qr/password:/i,
						sub {
								my $self = shift ;
								$self->send("$pass\n");                            
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
		); # end of exp 
	#the response after (yes/no)
	#Warning: Permanently added '192.168.0.2' (ECDSA) to the list of known hosts.
	#root@192.168.0.2's password:
				$exp->expect(2,[
						qr/password:/i,
						sub {
								my $self = shift ;
								$self->send("$pass\n");      
							}
					]);	
	
	$exp->send ("\n");
	$exp -> send("rm -rf /root/\.ssh\n") if ($exp->expect(2,'#'));
   	$exp -> send("mkdir  /root/\.ssh\n") if ($exp->expect(2,'#'));
    $exp -> send("chmod 700 /root/\.ssh\n") if ($exp->expect(2,'#'));
	$exp -> send("exit\n") if ($exp->expect(2,'#'));
	$exp->soft_close();
$pm->finish;
} # end of loop

$pm->wait_all_children;
# Beign scp

for (@avaIP){	
	$pm->start and next;
	my $exp = Expect->new;
	$exp = Expect->spawn("scp  /root/\.ssh/authorized_keys root\@$_:/root/\.ssh/ \n");
    $exp->expect(2,[
                    qr/password:/i,
                    sub {
                            my $self = shift ;
                            $self->send("$pass\n");                            
                            exp_continue;
                           }
                ],
                [
                    qr/connecting \(yes\/no\)/i,
                    sub {
                            my $self = shift ;
                             $self->send("yes\n");					        
                             #Are you sure you want to continue connecting (yes/no)?
                         }
                ]
     ); # end of exp 
#the response after (yes/no)
#Warning: Permanently added '192.168.0.2' (ECDSA) to the list of known hosts.
#root@192.168.0.2's password:
               $exp->expect(2,[
                    qr/password:/i,
                    sub {
                            my $self = shift ;
                            $self->send("$pass\n");      
                        }
                ]);
	
	
#}
    $exp -> send("\n");
    $exp -> send("chmod 640 /root/\.ssh/authorized_keys\n") if ($exp->expect(2,'#'));
   	$exp -> send("/etc/init.d/sshd restart\n") if ($exp->expect(2,'#'));
	$exp -> send("exit\n") if ($exp->expect(2,'#'));
	$exp->soft_close();
	$pm->finish;
}# for loop

$pm->wait_all_children;

######## go through each node for the final passworless setting

for (@avaIP){	
	$pm->start and next;
	my $exp = Expect->new;
	$exp = Expect->spawn("ssh -l root $_ \n");
	$exp->expect(2,[
						qr/password:/i,
						sub {
								my $self = shift ;
								$self->send("$pass\n");                            
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
		); # end of exp 
	#the response after (yes/no)
	#Warning: Permanently added '192.168.0.2' (ECDSA) to the list of known hosts.
	#root@192.168.0.2's password:
				$exp->expect(2,[
						qr/password:/i,
						sub {
								my $self = shift ;
								$self->send("$pass\n");      
							}
					]);	
	
	$exp->send ("\n");
	$exp -> send("exit\n") if ($exp->expect(2,'#'));
	$exp->soft_close();
	$pm->finish;
} # end of loop

$pm->wait_all_children;

######## go through each node for the final passworless setting

for (0..$#avaIP){
	$pm->start and next;
	$temp=$_+1;
    $nodeindex=sprintf("%02d",$temp);
    $nodename= "node"."$nodeindex";	
    print "**$_ $nodename**\n";
	my $exp = Expect->new;
	$exp = Expect->spawn("ssh $nodename \n");
	$exp->expect(2,[
						qr/password:/i,
						sub {
								my $self = shift ;
								$self->send("$pass\n");                            
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
		); # end of exp 
				$exp->expect(2,[
						qr/password:/i,
						sub {
								my $self = shift ;
								$self->send("$pass\n");      
							}
					]);	
	
	$exp->send ("\n");
	$exp -> send("exit\n") if ($exp->expect(2,'#'));
	$exp->soft_close();
	$pm->finish;
} # end of loop
$pm->wait_all_children;
print "\n\n***###05root_rsa.pl: root passwordless setting done******\n\n";
