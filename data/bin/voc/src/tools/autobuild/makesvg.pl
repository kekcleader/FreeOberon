#!perl -w
use strict;
use warnings;


my %BuildStatus = ();
my $Rows = 0;
opendir DIR, "logs";
while (my $fn = readdir(DIR)) {
  if ($fn =~ /^((.+)-(.+))\.state$/) {
    my ($build, $branch, $id) = ($1, $2, $3);
    open STATE, "<logs/$fn";
    my @state = split(" ", <STATE>);  # date time os compiler model compiler-build library-build ssource-change binary-change tests
    splice(@state, 2, 0, $branch);
    $BuildStatus{$build} = \@state;
    close STATE;
    $Rows++;
  }
}
closedir DIR;

#for my $fn (sort keys %BuildStatus) {
#  print "$fn:\n";
#  my @state = @{$BuildStatus{$fn}};
#  my $i = 0;
#  for my $val (@state) {
#    print "  $i: $val\n";
#    $i++;
#  }
#}


my $FontHeight = 12;
my $LineHeight = 16;

sub svgtext {
  my ($f, $x, $y, $colour, $msg) = @_;
  if ($msg ne '') {
    $y = ($y+1)*$LineHeight + $FontHeight*0.4;
    print $f <<"--END--TEXT--";
<text x="$x" y="$y" fill="$colour">$msg</text>
--END--TEXT--
  }
}

sub ColourFor {
  my ($str) = @_;
  if ($str eq "Failed")   {return "#e03030";}  # red
  if ($str eq "Changed")  {return "#ff9d4d";}  # amber
  if ($str eq "Passed")   {return "#5adb5a";}  # green
  if ($str eq "Built")    {return "#5adb5a";}  # green
  return "#c0c0c0";
}


my @ColWidths = (22, 81, 67, 60, 70, 60, 50, 60, 60, 80, 80, 64);
my @Columns = (0);
for my $width (@ColWidths) {push @Columns, $Columns[$#Columns] + $width}

my $Width  = $Columns[$#Columns];
my $Height = ($Rows+2.2) * $LineHeight;



open(my $svg, ">vishaps-status.svg") // die "Could not create vishaps-status.svg.";

print $svg <<"--END--SVG--HEADER--";
<svg xmlns="http://www.w3.org/2000/svg"
     width="$Width" height="$Height"
     font-family="Verdana" font-size="${FontHeight}px" fill="#c0c0c0">

<rect x="3" y="3" width="@{[$Width-6]}" height="@{[$Height-6]}"
      rx="20" ry="20" fill="#404040"
      stroke="#d5850d" stroke-width="4"/>
--END--SVG--HEADER--


svgtext($svg, $Columns[1],  0, "#e0e0e0", "Date");
svgtext($svg, $Columns[2],  0, "#e0e0e0", "Time");
svgtext($svg, $Columns[3],  0, "#e0e0e0", "Branch");
svgtext($svg, $Columns[4],  0, "#e0e0e0", "OS");
svgtext($svg, $Columns[5],  0, "#e0e0e0", "Compiler");
svgtext($svg, $Columns[6],  0, "#e0e0e0", "Model");
svgtext($svg, $Columns[7],  0, "#e0e0e0", "Oberon");
svgtext($svg, $Columns[8],  0, "#e0e0e0", "Library");
svgtext($svg, $Columns[9],  0, "#e0e0e0", "C Source");
svgtext($svg, $Columns[10], 0, "#e0e0e0", "Assembler");
svgtext($svg, $Columns[11], 0, "#e0e0e0", "Tests");


my $Row = 1;
for my $build (sort keys %BuildStatus) {
  my @state = @{$BuildStatus{$build}};

  my $y = $Row*$LineHeight + $FontHeight*0.8;
  my $h = $LineHeight * 0.9;
  print $svg <<"--END--HIGHLIGHT--";
<a href="https://www.brownsmeet.com/githubhook/$build" target="_blank">
<rect x="20" y="$y" width="720" height="$h" fill="#404040"/>
--END--HIGHLIGHT--

  my $column = 1;
  for my $field (@state) {
    svgtext($svg, $Columns[$column], $Row, ColourFor($field), $field);
    $column++;
  }
  $Row++;

  print $svg "</a>\n"
}

print $svg "</svg>\n";
close $svg;
