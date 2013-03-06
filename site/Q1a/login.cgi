#!/usr/bin/perl

read( STDIN, $query, $ENV{"CONTENT_LENGTH"} );
@pairs = split( /&/, $query );
foreach $pair ( @pairs )
{
  ($name,$value) = split( /=/, $pair );
  $param{$name} = $value;
}

$valid = 0;
open( PASSWD, "./passwd" ) || die;
while ( <PASSWD> )
{
  chomp;
  ($name, $pwd) = split( /:/ );
  if ( $name eq $param{"id"} )
  {
    if ( $pwd eq $param{"passwd"} )
    {
      $valid = 1;
    }
  }
}
close( PASSWD );

print "Content-type: text/html\n";
if ( $valid == 1 )
{
  print "Set-Cookie: id=$name\n\n";
  print "<html><head><title>Welcome</title></head>\n";
  print "<body>\n";
  print "Welcome here $name\n";
  print "</body></html>\n";
}
else
{
  print "\n<html><head><title>Sorry</title></head>\n";
  print "<body>\n";
  print "I have no idea who you are!!!<br><br>\n";
  print "$param{'id'} $param{'passwd'}";
  print "</body></html>\n";
}
