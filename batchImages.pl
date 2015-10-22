#	BATCH IMAGE PROCESSOR FOR Lee'sAdventureSports.com
#
#	This fantastic little script takes all the image files
#	in one folder (see $source) and hacks 'em up into:
#		FOR UPLOADS
#		* {image}_lg.jpg (1050px/1050px)
#		* {image}_med.jpg (350px/350px)
#		* {image}_sw.jpg (350px/350px)**
#		FOR ECI
#		* {image}.jpg (350px/350px)
#		* {image}t.jpg (100px/100px)
#	saved in another folder (see $dest and $eci)
#	
#	**the swatch has to be manually chopped down to 25x25px
#	requires ImageMagick and PerlMagick be installed


use strict;
use warnings;
use Image::Magick;			
use File::Basename;

my $source = "C:/Documents and Settings/pos/My Documents/Downloads/WebAssets";
my $dest = "R:/RETAIL/IMAGES/4Web";
my $eci = "R:/RETAIL/RPRO/Images/Inven";
my $dir = $source;
my @files;
my $lg = 1050;
my $med = 350;
my $t = 100;
my $sw = 25;

main();

sub main {

	opendir DIR, $dir or die "cannot open dir $dir: $!";
	@files = grep { $_ =~ /.jpg/ || /.png/ || /.jpeg/ || /.gif/ } readdir DIR;
	closedir DIR;

	foreach(@files) {
		my($image, $x);

		#prepend full path for file
		my $path = $dir."/".$_;
		#get filename sans extension
		my $fh = fileparse($_, qr/\.[^.]*/);

		#open file
		$image = Image::Magick->new;
		$x = $image->Read($path);

		#set to 72ppi resolution
		$x = $image->Set(density=>'72x72');
		warn "$x" if "$x";
		
		#set color profile to RGB
		$x = $image->Quantize(colorspace=>'RGB');
		warn "$x" if "$x";

		#get width/height, ratio and reverse-ratio
		my $ww = $image->Get('width');
		my $hh = $image->Get('height');
		my $ratio = $ww/$hh;
		my $rratio = $hh/$ww;

		if( $ratio < 1 ) {
			$x = $image->Sample(geometry=>$lg."x".$lg);
			warn "$x" if "$x";
			$x = $image->Extent(geometry=>$lg."x".$lg, gravity=>"Center", background=>"#ffffff");
			warn "$x" if "$x";
		} elsif ( $ratio > 1 ) {
			$x = $image->Sample(geometry=>$lg."x".$lg);
			warn "$x" if "$x";
			$x = $image->Extent(geometry=>$lg."x".$lg, gravity=>"Center", background=>"#ffffff");
			warn "$x" if "$x";
		} else {
			$x = $image->Sample(geometry=>$lg."x".$lg);
			warn "$x" if "$x";
		}

		#save large
		$x = $image->Write("$dest/$fh\_lg.jpg");
		warn "$x" if "$x";

		#save medium
		$x = $image->Resize(geometry=>$med."x".$med);
		warn "$x" if "$x";
		$x = $image->Write("$dest/$fh\_med.jpg");
		warn "$x" if "$x";
		#save to eci
		$x = $image->Write("$eci/$fh".".jpg");
		warn "$x" if "$x";
		#outputs something we can manually make into a swatch
		$x = $image->Write("$dest/$fh\_sw.jpg");
		warn "$x" if "$x";

		#save thumbnail
		$x = $image->Sample(geometry=>$t."x".$t);
		warn "$x" if "$x";
		$x = $image->Write("$eci/$fh"."t.jpg");
		warn "$x" if "$x";
	}
}

