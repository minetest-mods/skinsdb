#!/bin/sh
# This script is used to generate the previews needed by the mod
# It requires blender with the latest python API (2.6x is tested)
# A script that works with older blenders and, maybe, without python, is available in older commits.
# This script can also use pngcrush and imagemagick to reduce output size,
#   please enable them if you want to push to the git repository of the mod.
# Pngcrush output will be written to .previews/pngcrush_output
# Warning: any file in .previews/ and u_skins/textures might be deleted without asking.
PNGCRUSH=true
IMAGEMAGICK=true
cd .previews
rm ../u_skins/textures/*_preview*.png # Remove all previous previews
blender -b skin_previews.blend --python-text "Generate previews" > /dev/null
if $IMAGEMAGICK
	then echo "Stripping metadata from generated files..."
	else echo "Moving files..."
fi
rm -rf output # remove my output
mkdir -p output
for i in blender_out/character_*_00.png;
do
	out_name=$(basename $i | sed -e 's/_00.png//g')
	out_file=output/"$out_name"_preview.png
	if $IMAGEMAGICK
	then
		convert -strip $i $out_file
	else
		mv $i $out_file
	fi
done
for i in blender_out/character_*_01.png;
do
	out_name=$(basename $i | sed -e 's/_01.png//g')
	out_file=output/"$out_name"_preview_back.png
	if $IMAGEMAGICK
	then
		convert -strip $i $out_file
	else
		mv $i $out_file
	fi
done
if $PNGCRUSH
	then
		echo "Running pngcrush..."
		pngcrush -d ../u_skins/textures/ output/*_preview*.png 2> pngcrush_output
	else mv output/*_preview*.png ../u_skins/textures/
fi
echo "Done !"
