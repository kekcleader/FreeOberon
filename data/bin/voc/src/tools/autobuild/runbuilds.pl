#!perl -w
use strict;
use warnings;
use POSIX "strftime";

$SIG{CHLD} = 'IGNORE';

my $home = "/home/dave/vishap-build";

chdir $home;
mkdir "logs";
#my $GlobalLog = *STDOUT;
open my $GlobalLog, ">$home/logs/runbuilds.log";

my $LogToScreenToo = 1;


# Find a build to run

sub FindTriggeredBuild {
  opendir (DIR, "$home") || die "$!";
  my $branch = undef;
  while ((!defined $branch)  &&  (my $fn = readdir DIR)) {
    if ($fn =~ /^trigger-(\w+)/) {$branch = $1;  unlink "$home/$fn"}
  }
  closedir DIR;
  return $branch;
}




# Status information
#
# Build type: Datestamp Branch Platform Compiler Model
# Status:     Compiler-build Library-build C-changed Assembler? Tests
#

my %BuildStatus = ();

sub WriteStatus {my ($timestamp, $id) = @_;
  open STATE, ">logs/$id.state";
  print STATE "$timestamp ";
  print STATE $BuildStatus{$id}->{kind},    ' ';
  print STATE $BuildStatus{$id}->{compile}, ' ';
  print STATE $BuildStatus{$id}->{library}, ' ';
  print STATE $BuildStatus{$id}->{csource}, ' ';
  print STATE $BuildStatus{$id}->{binary},  ' ';
  print STATE $BuildStatus{$id}->{tests},   "\n";
  close STATE;
}

sub SetStatus {my ($timestamp, $id, $section, $state) = @_;
  if (!exists $BuildStatus{$id}) {$BuildStatus{$id} = {
    kind => "- - -",      compile => "Pending", library => "Pending",
    csource => "Pending", binary => "Pending",  tests => "Pending"
  }}
  $BuildStatus{$id}->{$section} = $state;
  WriteStatus($timestamp, $id)
}


sub UpdateStatus {my ($timestamp, $id, $msg) = @_;
  if ($msg =~ /^Configuration: ([^ ]+) \[[0-9\/]+\] for ([^ ]+) ([^ ]+) on ([^ ]+)/) {
    SetStatus($timestamp, $id, 'kind', "$4 $2 $3")
  } else {
    if ($msg =~ /^--- (.*) ---$/) {
      my $status = $1;
      if    ($status eq 'Build starts')              {$id =~ /^.+?-(.+)$/; SetStatus($timestamp, $id, 'kind', "($1 rsync) -")}
      elsif ($status eq 'Compiler build started')                         {SetStatus($timestamp, $id, 'compile', 'Busy')}
      elsif ($status eq 'Compiler build successfull')                     {SetStatus($timestamp, $id, 'compile', 'Built')}
      elsif ($status eq 'Library build started')                          {SetStatus($timestamp, $id, 'library', 'Busy')}
      elsif ($status eq 'Library build successfull')                      {SetStatus($timestamp, $id, 'library', 'Built')}
      elsif ($status eq 'Generated c source files match bootstrap')       {SetStatus($timestamp, $id, 'csource', 'Unchanged')}
      elsif ($status eq 'Generated c source files differ from bootstrap') {SetStatus($timestamp, $id, 'csource', 'Changed')}
      elsif ($status eq 'Generated code unchanged')                       {SetStatus($timestamp, $id, 'binary',  'Unchanged')}
      elsif ($status eq 'Generated code changed')                         {SetStatus($timestamp, $id, 'binary',  'Changed')}
      elsif ($status eq 'Confidence tests started')                       {SetStatus($timestamp, $id, 'tests',   'Busy')}
      elsif ($status eq 'Confidence tests passed')                        {SetStatus($timestamp, $id, 'tests',   'Passed')}
      elsif ($status eq 'Build ends') {
        my %status = %{$BuildStatus{$id}};
        foreach my $sec (keys %status) {
          if ($status{$sec} eq 'Busy')    {$BuildStatus{$id}->{$sec} = 'Failed'}
          if ($status{$sec} eq 'Pending') {$BuildStatus{$id}->{$sec} = '-'}
        }
        WriteStatus($timestamp, $id)
      }
    }
  }
}


sub Log {my ($log, $id, $msg) = @_;
  my $timestamp = strftime("%Y/%m/%d %H.%M.%S", localtime);
  $msg =~ s/[\r\n]*$//;  # Remove trailing newline characters
  UpdateStatus($timestamp, $id, $msg);
  substr($timestamp,0,11) = ''; #  Remove date part as not needed in logs
  if ($LogToScreenToo) {print "($id) $timestamp $msg\n"}
  print $GlobalLog "$timestamp ($id) $msg\n";
  if (defined $log) {print $log "$timestamp $msg\n"}
}


sub DoLogged {my ($log, $id, $cmd) = @_;
  Log $log, $id, "Executing '$cmd'.";
  open(my $pipe, "$cmd 2>&1 |") // die "Could not open pipe from command $cmd.";
  while (<$pipe>) {Log $log, $id, $_}
  close($pipe);
}



sub SendFile {my ($log, $id, $dest, $port, $filename, $content) = @_;
  Log $log, $id, "SendFile($dest,$port,$filename)";
  open PIPE, "|ssh -p $port $dest 'cat >$filename'";
  $content =~ s/\n/\r\n/g;  # Unix to MS line ends.
  print PIPE $content;
  close PIPE;
}



##  my %machines = (
##    "cygwin32" => ['5932', 'dave@wax',                        'sh build-oberon.sh  n     oberon/cygwin/voc           gcc     '                  . $branch],
##    "cygwin64" => ['5932', 'dave@wax',        'sh start64.sh \'sh build-oberon.sh  n     oberon/cygwin/voc           gcc     '                  . $branch . '\''],
##    "mingw32"  => ['5932', 'dave@wax',                        'sh build-oberon.sh  n     oberon/mingw/voc            i686-w64-mingw32-gcc   ' . $branch],
##    "mingw64"  => ['5932', 'dave@wax',        'sh start64.sh \'sh build-oberon.sh  n     oberon/mingw/voc            x86_64-w64-mingw32-gcc ' . $branch . '\''],
##    "ce64"     => ['5922', 'obe@www',                         'sh build-oberon.sh  sudo  vishap/voc                  gcc     '                  . $branch],
##  );




my @Builds = (
  ['pi',       'pi@pie',     '22',    '',     'cd vishaps/$id && make full'],
  ['android',  'and',        '8022',  '',     'cd vishaps/$id && CC=gcc make full'],
  ['lub32',    'vim-lub32',  '22',    '',     'cd vishaps/$id && make full'],
  ['lub32cl',  'vim-lub32',  '22',    '',     'cd vishaps/$id && CC=clang make full'],
  ['obs32',    'vim-obs32',  '22',    '',     'cd vishaps/$id && make full'],
  ['cyg32',    'wax',        '5932',  '',     'cd vishaps/$id && make full'],
  ['ming32',   'wax',        '5932',  '',     'cd vishaps/$id && CC=i686-w64-mingw32-gcc make full'],
  ['cyg64',    'wax',        '5932',  '',     'sh start64.sh \'cd vishaps/$id && make full\''],
  ['ming64',   'wax',        '5932',  '',     'sh start64.sh \'cd vishaps/$id && CC=x86_64-w64-mingw32-gcc make full\''],
  ['lub64',    'vim',        '22',    '',     'cd vishaps/$id && make full'],
  ['osu64',    'vim-osu64',  '22',    '',     'cd vishaps/$id && make full'],
  ['fed64',    'vim-fed64',  '22',    '',     'cd vishaps/$id && make full'],
  ['fbs64',    'githubhook', '22',    '',     'cd vishaps/$id && make full'],
  ['ce64',     'vim-ce64',   '22',    '',     'cd vishaps/$id && make full'],
  ['darwin',   'dcb',        '22',    '',     'cd vishaps/$id && make full'],
  ['win32',    'vim-win64',  '22',    'x86',  'cmd /c x86.cmd'],
  ['win64',    'vim-win64',  '22',    'x64',  'cmd /c x64.cmd']
);

sub Prepare {my ($log, $id, $dest, $port, $preparation) = @_;
  SendFile($log, $id, $dest, $port, "$preparation.cmd", <<"--END--MS--");
call \"C:\\Program Files (x86)\\Microsoft Visual C++ Build Tools\\vcbuildtools.bat\" $preparation
cd %HOME%\\vishaps\\$id
make full
--END--MS--
}

sub BuildBranch {my ($branch) = @_;
  Log undef, $branch, "$branch branch build triggered.";

  # Obtain a clean clone of vishaps
  DoLogged undef, $branch, "rm -rf $home/voc";
  DoLogged undef, $branch, "cd $home && git clone -b $branch --single-branch https://github.com/vishaps/voc";

  # Start each build in turn

  unlink glob "$home/logs/$branch-*";
  for my $build (@Builds) {
    my ($id, $dest, $port, $preparation, $command) = @$build;
    my $rsynccompress = "-z";  if ($id eq "android") {$rsynccompress = "-zz"}
    $id = "$branch-$id";
    my $child = fork;  if (not defined $child) {die "Fork failed.";}
    if ($child) {print "Opened process $child for build $id at $dest.\n"}
    else {
      # child process
      my $log;
      open $log, ">$home/logs/$id.log";
      Log $log, $id, "--- Build starts ---";
      Log $log, $id, strftime("%Y/%m/%d ", localtime) . "Build $id starting at $dest.";
      DoLogged $log, $id, "ssh -p $port $dest mkdir -p vishaps/$id";
      DoLogged $log, $id, "rsync -r $rsynccompress --delete -e 'ssh -p $port' $home/voc/ $dest:vishaps/$id/";
      if ($preparation ne '') {Prepare($log, $id, $dest, $port, $preparation)}
      $command =~ s/\$id /$id /g;
      DoLogged $log, $id, "ssh -p $port $dest \"$command\"";
      Log $log, $id, "Build $id for branch $branch at $dest completed.";
      Log $log, $id, "--- Build ends ---";
      close $log;
      exit;
    }
  }

  Log undef, $branch, "$branch branch: all builds started.";
}



Log undef, 'runbuilds', strftime("%Y/%m/%d ", localtime) . "runbuilds starting.";
while (my $branch = FindTriggeredBuild()) {BuildBranch($branch)}
Log undef, 'runbuilds', "No more build triggers found, runbuilds complete.";
close $GlobalLog;

