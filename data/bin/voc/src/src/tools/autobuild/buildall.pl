#!perl -w
use strict;
use warnings;
use POSIX "strftime";
use Cwd;

my $branch = "master";
if (defined($ARGV[0]) && ($ARGV[0] ne "")) {$branch = $ARGV[0]}

my %machines = (
  "pi"       => ['22',   'pi@pie',                          'sh build-oberon.sh  sudo  projects/oberon/vishap/voc  gcc     '                  . $branch],
  "darwin"   => ['22',   'dave@dcb',                        'sh build-oberon.sh  sudo  projects/oberon/vishap/voc  clang   '                  . $branch],
  "cygwin32" => ['5932', 'dave@wax',                        'sh build-oberon.sh  n     oberon/cygwin/voc           gcc     '                  . $branch],
  "cygwin64" => ['5932', 'dave@wax',        'sh start64.sh \'sh build-oberon.sh  n     oberon/cygwin/voc           gcc     '                  . $branch . '\''],
  "mingw32"  => ['5932', 'dave@wax',                        'sh build-oberon.sh  n     oberon/mingw/voc            i686-w64-mingw32-gcc   ' . $branch],
  "mingw64"  => ['5932', 'dave@wax',        'sh start64.sh \'sh build-oberon.sh  n     oberon/mingw/voc            x86_64-w64-mingw32-gcc ' . $branch . '\''],
  "android"  => ['8022', 'root@and',                        'sh build-oberon.sh  n     vishap/voc                  gcc     '                  . $branch],
  "lub64"    => ['22',   'dave@vim',                        'sh build-oberon.sh  sudo  oberon/voc                  gcc     '                  . $branch],
  "lub32"    => ['22',   'dave@vim-lub32',                  'sh build-oberon.sh  sudo  oberon/voc                  gcc     '                  . $branch],
  "fed64"    => ['22',   'dave@vim-fed64',                  'sh build-oberon.sh  sudo  oberon/voc                  gcc     '                  . $branch],
  "osu64"    => ['22',   'dave@vim-osu64',                  'sh build-oberon.sh  sudo  oberon/voc                  gcc     '                  . $branch],
  "obs32"    => ['22',   'dave@vim-obs32',                  'sh build-oberon.sh  n     vishap/voc                  gcc     '                  . $branch],
  "win32"    => ['22',   'dave@vim-win64',                  'sh build-oberon.sh  n     msc-x86/voc                 msc-x86 '                  . $branch],
  "win64"    => ['22',   'dave@vim-win64',                  'sh build-oberon.sh  n     msc-x64/voc                 msc-x64 '                  . $branch],
  "ce64"     => ['5922', 'obe@www',                         'sh build-oberon.sh  sudo  vishap/voc                  gcc     '                  . $branch],
  "fb64"     => ['22',   'root@oberon',                     'sh build-oberon.sh  n     vishap/voc                  gcc     '                  . $branch]
);

sub logged {
  my ($cmd, $id) = @_;
  my $child = fork;
  if (not defined $child) {die "Fork failed.";}
  if ($child) {
    # parent process
    print "Started $id, pid = $child\n";
  } else {
    # child process
    open(my $log, ">log/$id.log") // die "Could not create log file log/$id.log";
    print $log strftime("%Y/%m/%d %H.%M.%S ", localtime), "$id.log\n";
    print $log strftime("%H.%M.%S", localtime), "> $cmd\n";
    print $id, " ", strftime("%H.%M.%S", localtime), "> $cmd\n";
    open(my $pipe, "$cmd 2>&1 |") // die "Could not open pipe from command $cmd.";
    while (<$pipe>) {
      my $line = $_;
      print $id, " ", strftime("%H.%M.%S", localtime), " ", $line;
      print $log strftime("%H.%M.%S", localtime), " ", $line;
    }
    close($pipe);
    print $log strftime("%H.%M.%S", localtime), " --- Make completed ---\n";
    close($log);
    exit;
  }
}

unlink glob "log/*";

for my $machine (sort keys %machines) {
  my ($port, $login, $cmd) = @{$machines{$machine}};
  my $cmd = "scp -P $port build-oberon.sh $login:build-oberon.sh &&"
          . "ssh -p $port $login \"$cmd\"";
  logged($cmd, $machine);
}

system("perl report.pl $branch");
while ((my $pid = wait) > 0) {
  print "Child pid $pid completed.\n";
  system("perl report.pl $branch");
}
