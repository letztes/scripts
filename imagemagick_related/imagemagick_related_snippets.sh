#!/usr/bin/bash

# requires the imagemagick package installed, obviously
# mogrify does the same as convert and takes the same switches
# the difference is that convert writes to a new file and mogrify
# overwrites the existing files in place

# enhance contrast despite the minus instead the plus sigil
# when e.g. book pages were photographed in bad light conditions
mogrify -contrast -contrast -contrast -contrast -contrast *.jpg

# repeat if initially the amount of -contrast was not enough
mogrify -contrast -contrast -contrast -contrast -contrast *.jpg

# correct orientation if the book pages were photographed with a
# badly handheld smartphone
# smartphones tend to create photos in a constant landscape orientation
# with the width being always greater than the height but set the exif
# rotation setpoint to right-top or left-top instead depending on the
# angle detected by the smartphone's g-sensor
# so that not the -rotate switch but the -orient switch applies here
mogrify -orient 'right-top' *.jpg
