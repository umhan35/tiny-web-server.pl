#!/usr/local/bin/perl

use strict;
use warnings;

use Socket;

require "helper.pl";

sub rubyP { #print raw string
  my $arg = $_;

  use Data::Dumper;
  $Data::Dumper::Useqq = 1;
  print Dumper $arg;

}

my $protocol = getprotobyname 'tcp';

my $port = 15032;
my $server_addr = sockaddr_in($port, INADDR_ANY);

socket SERVER, AF_INET, SOCK_STREAM, $protocol
  or die "Unable to create socket: $!";

bind SERVER, $server_addr
  or die "Unable to bind: $!";

listen SERVER, SOMAXCONN;


print ">> Server running on port $port...\n";
while (accept CONNECTION, SERVER ) {
  select CONNECTION; $| = 1; select STDOUT;
  print "\n>> Client connected at ", scalar(localtime), "\n";

  my $isGet = 1;
  while (<CONNECTION>) {
    s/\r?\n//;
    my $msg = $_;
    rubyP "$msg";

    if ($msg  =~ /GET/) {
      setRequestMethodAndRequestUri($msg);
      processGet();
      last;
    }
    
    if ($msg  =~ /POST/) {
      setRequestMethodAndRequestUri($msg);
      $isGet = 0;
    }



    if ($isGet) { #isGet
      if ($msg eq "") {
        last;
      }
    }
    else { #isPost
      if ($msg  =~ /Content-Length/) {
        setContentLength($msg);
      }
      
      if ($msg eq "") {
        read(CONNECTION, $ENV{'QUERY_STRING'}, $ENV{'CONTENT_LENGTH'});
        processPost();
        last;
      }
    }
  }
  
  close CONNECTION;
  print ">> Client disconnected\n\n";
}

close SERVER;
