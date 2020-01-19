#!/bin/bash

# Actually does not renaming the image files but creating hard links.
# Recursively.
# I just found it hard to put the linking into a catchy script name.
# If you want to actually rename instead of copy then change cp to mv.
# Or you can delete the original directories after the script finishes.
# However, the directory hierachry will still be flattened to 1.


if [ -z "$2" ]; then
	echo ""
	echo "Usage:"
	echo "bash rename_fotos_to_exif_date.sh <source_directory> <target_directory>"
	echo "All arguments are positional."
	echo "All arguments are mandatory."
	exit 1
fi

source_directory=$1
target_directory=$2

if [ "$source_directory" = "$target_directory" ]; then
	echo ""
	echo "source_directory and target_directory must not be the same"
	exit 1
fi

# Create the target directory if it does not exist already
if ! mkdir -p "$target_directory"; then
	echo ""
	echo "could not create target directory $target_directory"
	exit 1
fi

# Do the actual work recursively:
# Flatten the directory hierarchy to 1
# Hard link with new file name if exif date for creation time exists
# Hard link with old file name otherwise
find "$source_directory" -type f -print0 | while IFS= read -r -d '' file
do 
	filename=$(basename -- "$file")
	extension="${filename##*.}"
	
   	creation_timestamp=$(identify -format "%[EXIF:DateTime]\n" "$file" 2>/dev/null | sed 's/://g' | sed 's/ /_/')
	if [ $creation_timestamp ]; then
		
		# Create a hard link with new filename
		cp -l "$file" "${target_directory}/${creation_timestamp}.${extension}"
	else
		
		# Create a hard link with old filename
		# Because some images have no exif information or are no images.
		cp -l "$file" "${target_directory}/${filename}"
	fi	
done
