
system("rm -rf /var/run/yum.pid");
#system("yum -y upgrade");

@package = ("vim", "wget", "net-tools", "epel-release", "htop", "make"
			, "gcc-c++", "nfs-utils", "ypserv" ,"yp-tools", "gcc-gfortran",,"psmisc"
			, "iptables-services", "ypbind" , "rpcbind");

#@package = ( "epel-release", "htop", "nfs-utils", "ypserv" ,"yp-tools", "ypbind" , "rpcbind");

foreach(@package){
    #system("yum -y remove $_");
    $check = system("yum -y install $_");
    #if($check !=0){die "Install $_ fails\n";}
    sleep(1);
}
system("yum -y upgrade");
