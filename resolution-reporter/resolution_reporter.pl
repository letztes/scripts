#!/usr/bin/perl
  
use strict;
use warnings;

use Getopt::Long;

my $min_height;
my $min_width;
my $directory;

GetOptions ("min_height|h=i" => \$min_height,
			"min_width|w=i"  => \$min_width,
			"directory|d=s"  => \$directory,
            );
            

# directory is mandatory
usage_message("\ndirectory is mandatory\n") if not $directory;

# at least one of min_height or min_width must be provided
usage_message("\none of min_height or min_width is mandatory\n") if (not $min_height and not $min_width);


my $command = 'find ' . $directory . ' -size +1000 -exec mediainfo --Inform="Video;%Height%" {} \; -exec mediainfo --Inform="Video;%Width%" {} \; -exec echo {} \; -exec echo \;';
my $movies_list = qx($command) or die $!;


=pod

=head2 example output of the system call

360
640
/foo/video530.mp4

360
640
/foo/video522.mp4

=cut

my @movies = split("\n", $movies_list);

# iterate over @movies
my $height_line = '';
my $width_line  = '';
my $path_line   = '';
foreach my $line (@movies) {
		
	# skip to next iteration on empty line
	if (not $line) {
		$height_line = '';
		$width_line  = '';
		$path_line   = '';
		next;
	}

	if (not $height_line) {
		
		# skip those that do not have numerical first element
		next if $line !~ /^\d+$/;

		# skip those whose first element is greater than $min_height
		next if $min_height and $line > $min_height;
		
		$height_line = $line;
		
		next;
	}

	if (not $width_line) {
		
		# skip those that do not have numerical second element
		next if $line !~ /^\d+$/;
		
		# skip those whose second element is greater than $min_width
		next if $min_width and $line > $min_width;
		
		$width_line = $line;
		
		next;
	}

	if (not $path_line) {

		$path_line = $line;
	}

	# print out the movie title and its dimension for too small movies
	print "height: $height_line\n";
	print "width:  $width_line\n";
	print "path:   $path_line\n";
	print "\n";
	
}
=pod

=head2 usage_message()

Print out which parameters to provide when calling the programm

=cut

sub usage_message {
	
	print shift; # print out the string that is the first argument

	print "\nExample usage:\n";
	print " perl $0 -d=/ -h=700 -w=1200\n\n";
	exit;
	
}
