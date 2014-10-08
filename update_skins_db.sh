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
temp=$PWD/tmp			# Where the temp folder will be. Default is $PWD/tmp, which means that the tmp folder will be put in the current folder
METADEST=$PWD/u_skins/meta		# This is the folder where the meta data will be saved
TEXTUREDEST=$PWD/u_skins/textures	# This is the folder where the skins and the previews will be saved


# === Make a bunch of folders and download the db ===
# ===================================================
if [ -d "$temp" ]; then
    rm -r $temp				# If the temp dir exists we will remove it and its contents.
fi
mkdir $temp				# Make a new temp dir. Redundant? No. We will get rid of it later.

if [ ! -d "$METADEST" ]; then		# Check to see if the meta dir exists, and if not, create it
  mkdir $METADEST
fi

if [ ! -d "$TEXTUREDEST" ]; then	# Check to see if the textures dir exists, and if not, create it
  mkdir $TEXTUREDEST
fi

wget $JSONURL -O $temp/rawdb.txt	# Download the entire database


# === Do the JSON thing ===
# =========================
i="0" 	# This will be the counter.
while [ "$ID" != "null" ] 	# Repeat for as long as there is data to process
  do
    ID=$(cat $temp/rawdb.txt | jq ".skins[$i].id")
    
    # The next lines are kinda complex. sed is being used to strip the quotes from the variables. I had help...
    meta_name=$(echo $(cat $temp/rawdb.txt | jq ".skins[$i].name") | sed -e 's/^"//'  -e 's/"$//')
    meta_author=$(echo $(cat $temp/rawdb.txt | jq ".skins[$i].author") | sed -e 's/^"//'  -e 's/"$//')
    meta_license=$(echo $(cat $temp/rawdb.txt | jq ".skins[$i].license") | sed -e 's/^"//'  -e 's/"$//')
    
    if [[ "$ID" != "null" ]]; then 	# Check to see if ID has a value
      echo "#"$ID "name:" $meta_name "author:" $meta_author "license:" $meta_license  # Verbosity to show that the script is working.      
      
      echo $meta_name > $METADEST/character_$ID.txt		# Save the meta data to files, this line overwrites the data inside the file
      echo $meta_author  >> $METADEST/character_$ID.txt		# Save the meta data to files, this line is added to the file
      echo $meta_license >> $METADEST/character_$ID.txt		# Save the meta data to files, and this line is added to the file as well.
      
      
      # === Extract and save the image from the JSON file ===
      # ======================================================
      skin=$(echo $(cat $temp/rawdb.txt | jq ".skins[$i].img") | sed -e 's/^"//'  -e 's/"$//') # Strip the quotes from the base64 encoded string
      echo $skin | base64 --decode > $TEXTUREDEST"/character_"$ID".png"		# Decode the string, and save it as a .png file
      
      
      # === Download a preview image whilst we're at it ===
      # ====================================================
      wget -nv $PREVIEWURL/$ID".png" -O $TEXTUREDEST"/character_"$ID"_preview.png"      # Downloads a preview of the skin that we just saved.
      
    fi
    i=$[$i+1] 	# Increase the counter by one.
  done

# === Now we'll clean up the mess ===
# ===================================
rm -r $temp	# Remove the temp dir and its contents.

exit # Not strictly needed, but i like to use it to wrap things up.
