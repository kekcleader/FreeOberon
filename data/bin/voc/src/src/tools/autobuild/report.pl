#!perl -w
use strict;
use warnings;
use POSIX "strftime";
use Cwd;

my $branch = "master";
if (defined($ARGV[0]) && ($ARGV[0] ne "")) {$branch = $ARGV[0]}

print "--- Running build status report on branch $branch.\n";

my %status = ();

my $fn;
my $date;
my $time;
my $os;
my $compiler;
my $datamodel;
my $compilerok;
my $libraryok;
my $sourcechange;
my $asmchange;
my $tests;
my $key;
my $ver;

sub clearvars {
  $time         = "";  $branch       = "";  $os           = "";  $compiler     = "";
  $datamodel    = "";  $compilerok   = "";  $libraryok    = "";  $sourcechange = "";
  $asmchange    = "";  $tests        = "";  $key          = "";  $ver          = "";
}

sub logstatus {
  my ($fn) = @_;
  if ($compiler ne "") {
    $status{"$os-$compiler-$datamodel"} =
      [$fn, $date, $time, $os, $compiler, $datamodel, $branch, $compilerok, $libraryok, $sourcechange, $asmchange, $tests];
  }
  clearvars();
}

sub parselog {
  ($fn) = @_;
  clearvars();
  open(my $log, $fn) // die "Couldn't open build log $fn.";
  $branch = "Build on $fn started";
  while (<$log>) {
    s/\r//g; # Remove unwanted MS command prompt CR's.

    if (/^([0-9\/]+) ([0-9.]+) .+\.log$/) {$date = $1}
    if (/^([0-9.]+) /)                    {$time = $1}

    #14.55.15 === build-oberon.sh: $1=sudo, $2=oberon/voc, $3=gcc, $4=master, $sudo=sudo ===
    if (/^[^ ]+ === build-oberon.sh: .* \$3=([^ ]+), \$4=([^ ]+),/) {
      ($compiler, $branch) = ($1, $2);
    }

    # 14.55.17 + sudo git checkout -f master
    if (/^[^ ]+ .*git checkout -f ([^ ]+) *$/) {
      $branch = $1;
    }

    # 14.55.17 Configuration: 2.1.0 [2016/12/22] for gcc ILP32 on ubuntu
    if (/^[^ ]+ Configuration: ([^ ]+) \[[0-9\/]+\] for ([^ ]+) ([^ ]+) on ([^ ]+)/) {
      ($ver, $compiler, $datamodel, $os) = ($1, $2, $3, $4);
      printf "--- Config for $fn: $1 for $2 $3 on $4.\n";
    }

   #if (/^[^ ]+ --- Cleaning branch ([^ ]+) ([^ ]+) ([^ ]+) ([^ ]+) ---$/) {
   #  ($branch, $os, $compiler, $datamodel) = ($1, $2, $3, $4, $5);
   #}

    if (/^([0-9.]+) --- Compiler build started ---$/)                         {$compilerok   = "Started";}
    if (/^([0-9.]+) --- Compiler build successfull ---$/)                     {$compilerok   = "Built";}

    if (/^([0-9.]+) --- Library build started ---$/)                          {$libraryok    = "Started";}
    if (/^([0-9.]+) --- Library build successfull ---$/)                      {$libraryok    = "Built";}

    if (/^([0-9.]+) --- Generated c source files match bootstrap ---$/)       {$sourcechange = "Unchanged";}
    if (/^([0-9.]+) --- Generated c source files differ from bootstrap ---$/) {$sourcechange = "Changed";}

    if (/^([0-9.]+) --- Generated code unchanged ---$/)                       {if ($asmchange eq "") {$asmchange = "Unchanged"}}
    if (/^([0-9.]+) --- Generated code changed ---$/)                         {$asmchange    = "Changed"}

    if (/^([0-9.]+) --- Confidence tests started ---$/)                       {$tests        = "Started";}
    if (/^([0-9.]+) --- Confidence tests passed ---$/)                        {$tests        = "Passed";}

    if (/^([0-9.]+) --- Make completed ---$/) {
      # Go back and convert 'Started' status to 'Failed'.
      if ($branch =~ m/^Build on/)  {$branch     = "Build on $fn failed to start.";}
      if ($compilerok eq "Started") {$compilerok = "Failed";}
      if ($libraryok  eq "Started") {$libraryok  = "Failed";}
      if ($tests      eq "Started") {$tests      = "Failed";}
      if ($compiler   eq "msc")     {$sourcechange = "n/a"; $tests = "n/a";}
    }
  }
  close($log);
  logstatus($fn);
}

opendir DIR, "log" // die "Could not open log directory.";
my @logs = readdir DIR;
closedir DIR;

for my $logname (sort @logs) {
  $logname = "log/" . $logname;
  #print "Consider $logname\n";
  if (-f $logname) {parselog($logname);}
}

my $fontheight = 12;
my $lineheight = 15;

sub svgtext {
  my ($f, $x, $y, $colour, $msg) = @_;
  print $f '<text x="', $x;
  print $f '" y="', ($y+1)*$lineheight + $fontheight*0.4;
  print $f '" font-family="Verdana" font-size="', $fontheight, 'px" fill="';
  print $f $colour;
  print $f '">';
  print $f $msg;
  print $f "</text>\n";
}

sub colourfor {
  my ($str) = @_;
  if ($str eq "Failed")   {return "#e03030";}
  if ($str eq "Changed")  {return "#ff9d4d";}
  if ($str eq "n/a")      {return "#707070";}
  return "#5adb5a";
}

my $rows = keys %status;

my $width  = 710;
my $height = ($rows+2.2) * $lineheight;

open(my $svg, ">build-status.svg") // die "Could not create build-status.svg.";
print $svg '<svg width="', $width, '" height="', $height, '"';
print $svg ' xmlns="http://www.w3.org/2000/svg" version="1.1"';
print $svg ' xmlns:xlink="http://www.w3.org/1999/xlink"', ">\n";
print $svg '<rect x="3" y="3" width="', $width-6, '" height="', $height-6, '"';
print $svg ' rx="20" ry="20" fill="#404040"';
print $svg ' stroke="#d5850d" stroke-width="4"/>', "\n";

my $col1  = 20;
my $col2  = 97;
my $col3  = 160;
my $col4  = 220;
my $col5  = 280;
my $col6  = 330;
my $col7  = 380;
my $col8  = 440;
my $col9  = 490;
my $col10 = 570;
my $col11 = 650;

svgtext($svg, $col1,  0, "#e0e0e0", "Date");
svgtext($svg, $col3,  0, "#e0e0e0", "Branch");
svgtext($svg, $col4,  0, "#e0e0e0", "Platform");
svgtext($svg, $col7,  0, "#e0e0e0", "Compiler");
svgtext($svg, $col8,  0, "#e0e0e0", "Library");
svgtext($svg, $col9,  0, "#e0e0e0", "C Source");
svgtext($svg, $col10, 0, "#e0e0e0", "Assembler");
svgtext($svg, $col11, 0, "#e0e0e0", "Tests");

my $i=1;
for my $key (sort keys %status) {
  my ($fn, $date, $time, $os, $compiler, $datamodel, $branch, $compilerok, $libraryok,
      $sourcechange, $asmchange, $tests) = @{$status{$key}};
  print $svg '<a xlink:href="', $fn, '">';
  svgtext($svg, $col1,  $i, "#c0c0c0", $date);
  svgtext($svg, $col2,  $i, "#c0c0c0", $time);
  svgtext($svg, $col3,  $i, "#c0c0c0", $branch);
  svgtext($svg, $col4,  $i, "#c0c0c0", $os);
  svgtext($svg, $col5,  $i, "#c0c0c0", $compiler);
  svgtext($svg, $col6,  $i, "#c0c0c0", $datamodel);
  svgtext($svg, $col7,  $i, colourfor($compilerok),   $compilerok);
  svgtext($svg, $col8,  $i, colourfor($libraryok),    $libraryok);
  svgtext($svg, $col9,  $i, colourfor($sourcechange), $sourcechange);
  svgtext($svg, $col10, $i, colourfor($asmchange),    $asmchange);
  svgtext($svg, $col11, $i, colourfor($tests),        $tests);
  print $svg '</a>';
  $i++;
}

print $svg "</svg>\n";

system 'chmod +r log/*';
system 'scp build-status.svg dave@hub:/var/www';
system 'scp log/* dave@hub:/var/www/log';
