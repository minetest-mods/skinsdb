#!/bin/bash
SPRITES=$(find -regextype sed -regex '.*/player_[0-9]\{1,\}.png' | sort -V)
MODELS=$(find -regextype sed -regex '.*/character_[0-9]\{1,\}.png' | sort -V)
function ask_for_meta {
	convert $2 -scale 100x200 /tmp/skins_set_meta
	SNAME=$(basename $1)
	SNAME=${SNAME%.*}
	METAFILE=u_skins/meta/$SNAME.txt
	FORCE=$3
	if $FORCE || ! [ -f $METAFILE ]
	then
		echo $METAFILE
		YADOUT=$(yad --form --image=/tmp/skins_set_meta --field $SNAME:LBL --field=Name --field=Author --field=Description --field=Comment)
		if [ -z "$YADOUT" ]; then exit; fi # canceled
		OIFS="$IFS"
		IFS='|'
		read -a VALUES <<< "$YADOUT"
		IFS="$OIFS"
		NAME=${VALUES[1]}
		AUTHOR=${VALUES[2]}
		DESCRIPTION=${VALUES[3]}
		COMMENT=${VALUES[4]}
		if [ -n "$NAME" ] && [ -n "$AUTHOR" ]
		then
			echo -n > $METAFILE # clear it
			echo 'name = "'$NAME'",' >> $METAFILE
			echo 'author = "'$AUTHOR'",' >> $METAFILE
			# only write description and comment if they are specified
			if [ -n "$DESCRIPTION" ]
			then
				echo 'description = "'$DESCRIPTION'",' >> $METAFILE
			fi
			if [ -n "$COMMENT" ]
			then
				echo 'comment = "'$COMMENT'",' >> $METAFILE
			fi
			echo "Saved !"
		fi
	fi
}
if [ -z $1 ]
then
	for i in $SPRITES
	do
		ask_for_meta $i $i false
	done
	for i in $MODELS
	do
		ask_for_meta $i ${i%.*}_preview.png false
	done
else
	if [ -f ${1%.*}_preview.png ]
	then
		ask_for_meta $1 ${1%.*}_preview.png true
	else
		ask_for_meta $1 $1 true
	fi
fi
rm /tmp/skins_set_meta
