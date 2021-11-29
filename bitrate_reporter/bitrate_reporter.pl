#!/usr/bin/perl
  
use strict;
use warnings;

use Getopt::Long;

my $min_bitrate;
my $directory;

GetOptions ("min_bitrate|b=i" => \$min_bitrate,
			"directory|d=s"  => \$directory,
            );
            

# directory is mandatory
usage_message("\ndirectory is mandatory\n") if not $directory;

# min_bitrate is mandatory
usage_message("\nmin_bitrate is mandatory\ne.g. 128000 for 128kb/s\n") if (not $min_bitrate);


my $command = 'find ' . $directory . ' -size +1000 -exec mediainfo --Inform="General;%OverallBitRate%" {} \; -exec echo {} \; -exec echo \;';

print "begin finding files...\n";
my $song_list = qx($command) or die $!;


=pod

=head2 example output of the system call

236252
/foo/awesome_song.ogg

64000
/foo/crappy_song.mp3

=cut

my @songs = split("\n", $song_list);
my $amount_of_files = scalar @songs;

# iterate over @songs
my $bitrate_line  = '';
my $path_line   = '';

print "begin iterating $amount_of_files files...\n";
foreach my $line (@songs) {
		
	# skip to next iteration on empty line
	if (not $line) {
		$bitrate_line  = '';
		$path_line   = '';
		next;
	}

	if (not $bitrate_line) {
		
		# skip those that do not have numerical first element
		next if $line !~ /^\d+$/;

		# skip those whose first element is greater than $min_bitrate
		next if $min_bitrate and $line > $min_bitrate;
		
		$bitrate_line = $line;
		
		next;
	}

	if (not $path_line) {

		$path_line = $line;
	}

	# print out the song title and its bitrate for too bad songs
	print "bitrate:  $bitrate_line\n";
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
	print " perl $0 -d=/ -b=128000\n\n";
	exit;
	
}
