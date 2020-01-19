#!/usr/bin/perl

# Actually does not renaming the image files but creating hard links.
# Recursively.
# I just found it hard to put the linking into a catchy script name.

use warnings;
use strict;

use Data::Dumper;

use File::Basename;
use File::Find;
use File::Path qw(make_path);
use Getopt::Long qw(:config gnu_getopt);

# sudo apt install libimage-exiftool-perl
use Image::ExifTool qw(:Public);

use POSIX qw( strftime );

# Mandatory parameters. Will be checked below.
my $source_directory = '';
my $target_directory = '';

# Default values 0 will be processed if the cli options were not given.
my $add_seconds      = 0;
my $subtract_seconds = 0;

GetOptions (
	'source_directory=s' => \$source_directory,
	'target_directory=s' => \$target_directory,
	'add_seconds=i'      => \$add_seconds,
	'subtract_seconds=i' => \$subtract_seconds,
);

if (not $source_directory or not $target_directory) {
	usage_message();
	exit 1;
}

# Each directory path must have exactly one trailing slash.
$source_directory =~ s/\/*$/\//;
$target_directory =~ s/\/*$/\//;

if ($source_directory eq $target_directory) {
	print "\nsource_directory and target_directory must not be the same\n";
	usage_message();
	exit 1;
}

sub usage_message {
	print "\nUsage:\n";
	print "perl rename_fotos_to_exif_date.pl --source_directory=<source_directory> --target_directory=<target_directory>\n";
	print "Optionally add an arbitrary amount of seconds to the exif creation date\n";
	print "to appear in the file name via --add_seconds=<add_seconds>\n";
	print "Subtract seconds via --subtract_seconds=<subtract_seconds>\n";
	exit 1,
}

# Create the target directory if it does not exist already.
make_path($target_directory, {'mode' => 0775,});
if (not -d $target_directory) {die "Could not create target directory $target_directory"}

my $exif_tool = new Image::ExifTool;

# Format date as epoch seconds.
$exif_tool->Options('DateFormat' => '%s');

# Do the actual work recursively:
# Flatten the directory hierarchy to 1
# Hard link with new file name if exif date for creation time exists
# Hard link with old file name otherwise

find(\&wanted, ($source_directory));

sub wanted {
	# return if current tree node is not a regular file
	return '' if ! -f $File::Find::name;
	
	my $info_href = $exif_tool->ImageInfo($File::Find::name) or return '';
	
	# Check the hashref for the creation date related keys
	# by grepping keys case insensitively and slicing their values.
	my @creation_date_keys = grep {/datetime/i} keys %{$info_href};
	my @creation_date_values = @{$info_href}{@creation_date_keys};
	
	# Only files with a creation date after 1990 are wanted.
	my @wanted_creation_date_values = grep {$_ > 631152000} @creation_date_values;
	
	# Take the first from the list of date values found so far.
	my $creation_date_value = $wanted_creation_date_values[0];
	
	my ($filename, $dirs, $suffix) = fileparse($File::Find::name, qr/\.[^.]*/);

	# hard links in perl:
	# link OLDFILE,NEWFILE
	if ($creation_date_value) {
		
		my $corrected_creation_date_value = $creation_date_value + $add_seconds - $subtract_seconds;
		
		my $formatted_creation_date = strftime '%Y%m%d_%H%M%S', localtime $corrected_creation_date_value;
		
		# Link old file with new file having the date value as a name.
		link $File::Find::name, $target_directory.'IMG_'.$formatted_creation_date.$suffix;
	}
	else {

		# link with old filename as name
		link $File::Find::name, $target_directory.$filename.$suffix;
	}
	
	return '';
}
