# resolution-reporter
Finds and reports video files with smaller than a given resolution.
If you want to get a list of all your movies and their resolutions
specify 0 for min_height and 0 for min_width.

## Example:
 perl resolution_reporter.pl -d=/ -h=700 -w=1200

This example would look up recursively all files on your file system
and report those whose height is not greater than 700 and whose
width is not greater than 1200.

## Dependencies:
* find
* mediainfo
