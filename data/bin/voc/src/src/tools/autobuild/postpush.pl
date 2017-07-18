#!/usr/bin/perl -w

use strict;
use warnings;
use POSIX "strftime";

use CGI qw(:standard escapeHTML);
use JSON;


sub writelog {
  my ($msg) = @_;

  open(LOG, ">>/tmp/postpush.log") or die "Could not create postpush.log";
  flock(LOG, 2)                    or die "Could not lock postpush.log";
  print LOG sprintf("%s %s\n", strftime("%Y/%m/%d %H.%M.%S", localtime), $msg);
  close(LOG);
  system "id >> /tmp/postpush.log";
}

my $postdata = from_json(param('POSTDATA'));

my $url      = $postdata->{'repository'}->{'url'};
my $ref      = $postdata->{'ref'};
my $name     = $postdata->{'head_commit'}->{'author'}->{'name'};
my $branch   = $ref;  $branch =~ s'^.*\/'';
my $repo     = $url;  $repo   =~ s'^.*\/'';
my $modified = $postdata->{'head_commit'}->{'modified'};

my $buildneeded = 0;
for my $file (@{$modified}) {
  if ($file !~ m/\.(md|svg)$/i) {$buildneeded = 1;}
}

if ($buildneeded) {
  writelog "Post push github web hook for repository $repo, branch $branch, name $name. Build required.";

  my $child = fork;
  if (not defined $child) {die "Fork failed.";}
  if ($child) {
    writelog "Started buildall, pid = $child.";  # parent process
  } else {
    close(STDIN); close(STDOUT); close(STDERR);  # child process
    exec 'perl buildall.pl ' . $branch . ' >/tmp/buildall.log';
    exit;
  }
} else {
  writelog "Post push github web hook for repository $repo, branch $branch, name $name. No build required.";
}


print header(),
  start_html("Vishap Oberon github post push web hook."),
  p("Repository $repo, branch $branch, name $name."),
  end_html();
