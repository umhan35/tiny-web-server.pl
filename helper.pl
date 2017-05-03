#!/usr/local/bin/perl

use strict;
use warnings;

sub puts {
  print "$_[0]\n";
}

sub p {
  print "DEBUG: '$_[0]'\n";
}

sub say {
  print CONNECTION $_[0];
}

sub processPost {
  my $uri = $ENV{'REQUEST_URI'};

  processFile($uri);
}

sub setContentLength {
  my $input = $_[0];
  my $blankPos = index($input, " ");
  my $contentLength = substr($input, $blankPos + 1);

  $ENV{'CONTENT_LENGTH'} = $contentLength;
  p "CONTENT_LENGTH: $ENV{'CONTENT_LENGTH'}";
}

sub processGet {
  my $uri = $ENV{'REQUEST_URI'};

  checkSetQueryString($uri);
  processFile($uri);
}

sub checkSetQueryString {
  my $uri = $_[0];
  
  if($uri =~ /\?/) { # has params
    my $params;
    ($uri, $params) = split(/\?/, $uri);
    $ENV{'QUERY_STRING'} = $params;
p "params(QUERY_STRING): " . $params;
  }
}

sub setRequestMethodAndRequestUri {
  my $input = $_[0];
  my ($method, $uri);

  ($method, $uri) = split / /, $input;
  
  $ENV{'REQUEST_METHOD'} = $method;
p "REQUEST_METHOD: " . $method;

  $ENV{'REQUEST_URI'} = $uri;
p "REQUEST_URI: " . $uri;
}

sub processFile {
  my $requestUri = $_[0];

  # generate uri
  my $root_dir = "./site";
  my $uri = $root_dir . $requestUri;
  if(-d $uri) { # dir
    $uri .= "/index.html";
  }
p "uri: $uri";

  # check and exe/read uri
  if (checkFile($uri) ) {
    processExistedFile($uri);
  }
}

sub checkFile {
  my $result;
  my $uri = $_[0];
  
  if(-e $uri) { # file exists?
p "'$uri' file exist";
    say "HTTP/1.1 200 OK\n"; # later add another \n 
    $result = 1;
  }
  else {
p "'$uri' file not exist";
    say "HTTP/1.1 404 Not Found\n\n";
    open(FOUR_0_FOUR_FILE, "404.html");
    while (<FOUR_0_FOUR_FILE>) {
      say $_;
    }
    $result = 0;
  }
  
  return $result;
}

sub processExistedFile {
  my $uri = $_[0];
  
  ### execute file
  if($uri =~ m/\.cgi$/) {
    my $toExe = $uri;
    
    if($ENV{'REQUEST_METHOD'} eq "POST") {
      $toExe = "echo \"$ENV{'QUERY_STRING'}\" | $uri";
    }
p "toExe: '$toExe'";

    my $ret = `$toExe`;
    say $ret;
  }
  ### read file
  else {
    open(MY_FILE, $uri) or die; # checked if file is existed in the checkFile subroutine, so die never happends
    
    say "\n"; # signal HTTP response end
    while (<MY_FILE>) {
      say $_;
    }
  }
}

#processGet "GET /test.txt HTTP/1.1"
#processGet "GET /env.cgi HTTP/1.1"
#processGet "GET /Q1a/q1.cgi HTTP/1.1"
#processGet "GET / HTTP/1.1"
#processGet "GET /Q1a/ HTTP/1.1"

1;
