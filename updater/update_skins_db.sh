#!/bin/bash
####
# Licenced under Attribution-NonCommercial-ShareAlike 4.0 International 
# http://creativecommons.org/licenses/by-nc-sa/4.0/
#### ATTENTION ####
## This script requires that jq and coreutils are installed on your system ##
## In Debian-based distros, open a terminal and run 
## 	sudo apt-get install jq coreutils
###################

# == Set variables ===
# ====================
NUMPAGES="1"	# Number of pages. Default is 1 page
PERPAGE="2000"  # Number of items per page. Default is 2000.
JSONURL="http://minetest.fensta.bplaced.net/api/get.json.php?getlist&page=$NUMPAGES&outformat=base64&per_page=$PERPAGE"	# The URL to the database
PREVIEWURL="http://minetest.fensta.bplaced.net/skins/1/"	# The url to the location of the previews.
curpath="$(dirname $0)"		# all path are relative to this script place
temp="$curpath"/tmp			# Where the temp folder will be. Default is $PWD/tmp, which means that the tmp folder will be put in the current folder
METADEST="$curpath"/../meta		# This is the folder where the meta data will be saved
TEXTUREDEST="$curpath"/../textures	# This is the folder where the skins and the previews will be saved

# === Make a bunch of folders and download the db ===
# ===================================================
if [ -d "$temp" ]; then
    rm -r $temp				# If the temp dir exists we will remove it and its contents.
fi
mkdir "$temp"				# Make a new temp dir. Redundant? No. We will get rid of it later.

if [ ! -d "$METADEST" ]; then		# Check to see if the meta dir exists, and if not, create it
  mkdir "$METADEST"
fi

if [ ! -d "$TEXTUREDEST" ]; then	# Check to see if the textures dir exists, and if not, create it
  mkdir "$TEXTUREDEST"
fi

wget "$JSONURL" -O "$temp"/rawdb.txt	# Download the entire database


# === Do the JSON thing ===
# =========================
i="0" 	# This will be the counter.
while true; do
   ID=$(cat "$temp"/rawdb.txt | jq ".skins[$i].id")
   if [ "$ID" == "null" ]; then
       break
   fi

   if [ ! -f "$METADEST"/character_$ID.txt ] || [ "$1" == "all" ]; then
      # The next lines are kinda complex. sed is being used to strip the quotes from the variables. I had help...
      meta_name="$(jq ".skins[$i].name" < "$temp"/rawdb.txt | sed 's/^"//;s/"$//')"
      meta_author="$(jq ".skins[$i].author" <"$temp"/rawdb.txt | sed 's/^"//;s/"$//')"
      meta_license="$(jq ".skins[$i].license" <"$temp"/rawdb.txt | sed 's/^"//;s/"$//')"

      echo "# $ID name: $meta_name author: $meta_author license: $meta_license"  # Verbosity to show that the script is working.

      echo "$meta_name" > "$METADEST"/character_$ID.txt			# Save the meta data to files, this line overwrites the data inside the file
      echo "$meta_author"  >> "$METADEST"/character_$ID.txt		# Save the meta data to files, this line is added to the file
      echo "$meta_license" >> "$METADEST"/character_$ID.txt		# Save the meta data to files, and this line is added to the file as well.


      # === Extract and save the image from the JSON file ===
      # ======================================================
      skin=$(jq ".skins[$i].img" < "$temp"/rawdb.txt | sed 's/^"//;s/"$//') 	# Strip the quotes from the base64 encoded string
      echo "$skin" | base64 --decode > "$TEXTUREDEST"/character_"$ID".png	# Decode the string, and save it as a .png file

      # === Download a preview image whilst we're at it ===
      # ====================================================
      wget -nv "$PREVIEWURL/$ID".png -O "$TEXTUREDEST"/character_"$ID"_preview.png	# Downloads a preview of the skin that we just saved.
   else
      echo -n "."
   fi
   i=$[$i+1] 	# Increase the counter by one.
done

# === Now we'll clean up the mess ===
# ===================================
rm -r "$temp"	# Remove the temp dir and its contents.

exit # Not strictly needed, but i like to use it to wrap things up.
