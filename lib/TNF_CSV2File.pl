use strict;
use warnings;

use File::Basename;
use Text::CSV;

my $file = $ARGV[0] or die "Need to get CSV file on the command line";
# my $file = "C:/Documents and Settings/pos/Desktop/BJ/Dir/TNF_Test/TNF_Test.csv";
my $dir = dirname($file);
my $csv;
my @rows;
my @row;

main();

#working on traversing a faked up multidimensional array
#use Data::Dumper qw(Dumper);
#print Dumper \@rows;



sub main {

	$csv = Text::CSV->new ({
		binary => 1
	}) or die "Cannot use CSV";
				 
	open(my $data, '<', $file) or die "Could not open '$file' $!\n";
	my $i = 0;
	while (my $row = $csv->getline($data)) {
		if( $i > 0 ) {
			chomp $row;
			@row = $row;
			rows_to_file();
		}
		$i++;
	}

	close $data;
}


#parse out to file
#!NEED TO CUSTOMIZE
#the column references for each csv
sub rows_to_file {
	my %csv_map = (
		"product_name" => 0,
		"product_id" => 1,
		"product_description" => 29,
		"color_index" => 7,
		"color_length" => 4,
		"feature_index" => 30,
		"feature_length" => 18,
		"fabric_index" => 24,
		"fabric_length" => 5,
		"weight" => 20
	);
	my $i = 0;
	for (@row) {

		#create a new file named the product code
		my $filename = $dir . "/$row[$i][$csv_map{product_id}].txt";
		open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";

		#grab the color codes and color names
		print $fh "COLORS:\n";
		for(my $j=0; $j<$csv_map{color_length}; $j++) {
			my $k = $j*3+$csv_map{color_index};
			if($row[$i][$k]) {
				print $fh "$row[$i][$k+1] - $row[$i][$k]\n";
			}
		}
		print $fh "\n";

		print $fh "<ECI>\n";
		print $fh "<FONT face=verdana>\n";
		print $fh "\t<H2>The North Face $row[$i][$csv_map{product_name}]</H2>\n";
		print $fh "\t<P>\n\t\t$row[$i][$csv_map{product_description}]\n\t</P>\n";

		#Features
		print $fh "\t<P>\n\t\t<U>Features:</U>\n\t\t<UL>\n";
			for(my $j=0; $j<$csv_map{feature_length} ; $j++) {
				my $k = $j+$csv_map{feature_index};
				if($row[$i][$k]) {
					print $fh "\t\t\t<LI>$row[$i][$k]</LI>\n";
				}
			}
		print $fh "\t\t</UL>\n\t</P>\n";

		#Specifications
		print $fh "\t<P>\n\t\t<U>Specifications:</U>\n\t\t<UL>\n";
			print $fh "\t\t\t<LI>Style: $row[$i][$csv_map{product_id}]</LI>\n";
			print $fh "\t\t\t<LI>Fabric: ";
			for(my $j=0; $j<$csv_map{fabric_length} ; $j++) {
				my $k = $j+$csv_map{fabric_index};
				if($row[$i][$k]) {
					print $fh "$row[$i][$k]<br>\n";
				}
			}
			print $fh "</LI>\n";
			if($csv_map{weight}) {
				print $fh "\t\t\t<LI>Weight: $row[$i][$csv_map{weight}]</LI>\n";
			}
		print $fh "\t\t</UL>\n\t</P>\n";

		#Space for sizing
		print $fh "\t<P>\n\t\t<U>^ Sizing ^</U><br>\n\n\t</P>\n";
		
		print $fh "</FONT>";

		close $filename;
		$i++;
	}

}
