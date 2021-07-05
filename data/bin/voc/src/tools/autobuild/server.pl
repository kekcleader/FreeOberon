#!/usr/bin/perl
use strict;
use warnings;
use HTTP::Daemon;
use HTTP::Status;
use HTTP::Response;
use HTTP::Date qw(time2str);
use LWP::MediaTypes qw(guess_media_type);
use Digest::SHA qw(hmac_sha1_hex);
use Data::Dumper;
use JSON;
use sigtrap qw(die INT QUIT);

my $home = "/home/dave/vishap-build";
my $criggleplop = "splurd crungle splonge.";

$| = 1;
$SIG{CHLD} = 'IGNORE';

my $PORT = 9000;
my $server = HTTP::Daemon->new(Family => AF_INET, LocalPort => $PORT, ReuseAddr => 1);
die "Cannot setup server" unless $server;
print "[$$: Accepting clients at http://localhost:$PORT/]\n";

while (my $client = $server->accept) {
  (my $pid = fork()) // die("Couldn't fork.");
  if ($pid) {$client->close; undef $client}
  else {ServeRequests($client); $client->close; undef $client; exit}
}
print "$$: server->accept failed. Exiting.\n";
exit;


sub StartBuilds {my ($branch) = @_;
  print "  -- start builds for branch $branch.\n";
  open TRIGGER, ">trigger-$branch"; print TRIGGER "trigger.\n"; close TRIGGER;
  my $running = 0;
  if (open PID, "<pid") {$running = kill 0, <PID>; close PID}
  if (!$running) {
    my $child = fork;
    if ($child) {
      # This is the parent. We get to know the child PID, write it out.
      print "Started build, pid $child.\n";
      open PID, ">pid";  print PID "$child.\n";  close PID;
    } else {
      # This is the child, we actually run all triggered builds.
      # print "Debug: About to run perl >$home/runbuilds.log ...\n";
      exec "perl $home/runbuilds.pl >$home/runbuilds.log";
      exit; # Shouldn't get here
    }
  }
}


sub decodehook {my ($hook) = @_;
  my %modifiedfiles = ();
  my %commitauthors = ();
  my $buildrequired = 0;

  my $commits = $hook->{commits};
  for my $commit (@$commits) {
    my $committer = $commit->{committer};
    $commitauthors{$committer->{username}}++;
    my $modified = $commit->{modified};
    for my $modfile (@$modified) {
      $modifiedfiles{$modfile}++;
      if ($modfile !~ m/\.(md|svg)$/i) {$buildrequired = 1;}
    }
  }
  my $pusher = $hook->{pusher};
  my $repository = $hook->{repository};
  my $branch = $hook->{ref};  $branch =~ s'^.*\/'';
  print "Repository: $repository->{name}, branch: $branch.\n";
  print "Commit authors: " . join(", ", keys %commitauthors) . ".\n";
  print "Pusher: " . $pusher->{name} . "\n";
  print "Files modified: " . join(", ", keys %modifiedfiles) . ".\n";
  print "Build " . ($buildrequired ? '' : 'not') . " required.\n";
  if ($buildrequired) {StartBuilds($branch)}
}


sub SendFile {my ($client, $file) = @_;
  my $CRLF = "\r\n";
  local(*F);
  sysopen(F, $file, 0);
  binmode(F);
  my($ct,$ce) = guess_media_type($file);
  my($size,$mtime) = (stat $file)[7,9];
  $client->send_basic_header;
  print $client "Content-Encoding: $ce$CRLF" if $ce;
  print $client "Last-Modified: ", time2str($mtime), "$CRLF" if $mtime;
  print $client "Accept-Ranges: bytes$CRLF";
  print $client "Content-Length: $size$CRLF" if $size;
  print $client "Cache-Control: no-cache, no-store, must-revalidate, max-age=0$CRLF";
  print $client "Pragma: no-cache$CRLF";
  print $client "Expires: Wed, 11 Jan 1984 05:00:00 GMT$CRLF";
  print $client "Content-Type: $ct$CRLF";
  print $client $CRLF;
  $client->send_file(\*F) unless $client->head_request;
}


sub VishapStatus {my ($client) = @_;
  print "  -- generate status.\n";
  system "perl makesvg.pl";  # Construct an up-to-date status file
  SendFile($client, "vishaps-status.svg");
}

sub LogFileResponse {my ($client, $path) = @_;
  if (-f "logs/$path.log") {
    print "  -- send log for build $path.\n";
    SendFile($client, "logs/$path.log")
  } else {
    print "  -- respond forbidden: no log for $path.\n";
    $client->send_error(RC_FORBIDDEN)
  }
}


sub ServeRequests {my ($client) = @_;
  $client->autoflush(1);
  while (my $request = $client->get_request) {
    if ($request->method eq 'GET') {

      my $host = $request->headers->{host};
      my $uri = $request->uri;
      $uri =~ s/^\///;
      $uri =~ s/^githubhook\///;

      print "Request: $uri\n";

      if    ($uri eq 'vishaps-status.svg') {VishapStatus($client)}
      elsif ($uri eq 'vishaps-trigger') {
        $client->send_file_response("response.html");
        StartBuilds("master");
      }
      elsif ($uri =~ /^vishaps-trigger\/([-_a-z0-9]+)/i) {
        $client->send_file_response("response.html");
        StartBuilds($1);
      }
      else {LogFileResponse($client, $uri)}

    } elsif ($request->method eq 'POST') {

      $client->send_file_response("response.html");
      my $event = $request->headers->{'x-github-event'};
      my $githubsig = substr($request->headers->{'x-hub-signature'}, 5);
      my $mysig = hmac_sha1_hex($request->content, $criggleplop);
      print "Github POST: $event, mysig $mysig, githubsig: $githubsig.\n";
      if (($event eq "push") &&  ($mysig eq $githubsig)) {
        my $content = $request->content;
        $content =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;  # Unescape %xx sequences.
        decodehook(JSON::decode_json(substr($content,8)));
      }

    } else {

      print "Request method $request->method forbidden.\n";
      $client->send_error(RC_FORBIDDEN)

    }
  }
}
