use strict;
use warnings;
 
use Text::CSV;

#my $file = $ARGV[0] or die "Need to get CSV file on the command line\n";
my $csvfile = "C:/Documents and Settings/pos/Desktop/BJ/TNFColors.csv";

# Set to filename of de-duped file (new file)
my $newfile = 'new.csv';

### Shouldn't need to change stuff below here ###

open (IN, "<$csvfile")  or die "Couldn't open input CSV file: $!";
open (OUT, ">$newfile") or die "Couldn't open output file: $!";

# Slurp in & sort everything else
my @data = <IN>;

my $n = 0;
# Now go through the data line by line, writing it to output unless
# it's identical
# to the previous line (in which case it's a dupe)
my $lastkey = '';
foreach my $row (@data) {
  my ($code,$color) = split /,/, $row;
  next if $code eq $lastkey;
  print OUT $row;
  $lastkey = $code;
  $n++;
}

close IN; close OUT;

print "Processing complete. In = " . scalar @data . " records, Out =
$n records\n";