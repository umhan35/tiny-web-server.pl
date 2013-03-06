#!/usr/bin/perl
$cookie = $ENV{'HTTP_COOKIE'};
($name,$value) = split( /=/, $cookie );

print "Content-type: text/html\n\n";
if ( $name eq "id" )
{
  print "<html><head><title>Welcome</title></head>\n";
  print "<body>\n";
  print "Welcome back $value\n";
  print "</body></html>\n";
}  
else
{
  print "<html><head><title>Log in</title></head>\n";
  print "<body>\n";
  print "<form method=POST action=login.cgi>\n";
  print "Please let me know who you are.<br><br>\n";
  print "Name: <input type=text name=\"id\"<br>\n";
  print "Password: <input type=password name=\"passwd\"<br>\n";
  print "<input type=submit value=\"log in\"><br>\n";
  print "</form>\n";
  print "</body></html>\n";
}