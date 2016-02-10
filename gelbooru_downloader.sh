#!/bin/bash
#---------------
#Gelbooru bulk downloader
#Uses tags and page count
#Downloads all images which match the tags on the selected pages
#---------------

TAGS=""
HOMEURL="http://www.gelbooru.com/index.php?page=post&s=list&tags="
URL_LINE=""
C=0 #images count
DEST_DIR="$HOME/gelbooru_imgs"
PICS_DIR=${DEST_DIR}

function welcome {
	echo Hi!
	if [ -d "$DEST_DIR" ]; then
		echo "Directory already exists. Will use it."
		sleep 0.5
	else
		mkdir $DEST_DIR
	fi
	echo "Enter pics destination directory (full path)"
	echo or leave empty to use $DEST_DIR
	if [ -n "$a" ]; then #if not empty
		PICS_DIR=${a}
		if [ -d "${PICS_DIR}" ]; then
			echo Will save to $PICS_DIR
			echo Now enter tags, one per line. 
		else
			mkdir $PICS_DIR
			echo Now enter tags, one per line.
		fi
	fi
		

}
function get_tags {
	while read line ; do #read tags
		line=`echo $line | sed -e "s/ /_/g" -e "s/:/%3a/g" -e "s/=/%3d/g"`
		TAGS=$TAGS$line+
	done
	
	TAGS=`echo $TAGS | sed -e "s/.$//g"` #cut last element
	URL_LINE=$HOMEURL$TAGS #form URL
}

function get_urls {
	if [ -e "$DEST_DIR/filelist" ]; then
		rm "$DEST_DIR/filelist"
		touch "$DEST_DIR/filelist"
	else	       
		touch "$DEST_DIR/filelist" #download formed URL
	fi

	wget $URL_LINE -q -O /tmp/gel.html
	#-----parse ids-----
	ID=`cat /tmp/gel.html | grep -o -E "a\ id=\"[a-zA-Z0-9]{1,}\""`
	TURL="http://www.gelbooru.com/index.php?page=post&s=view&id="
	RESID=""
	ID=`echo $ID | grep -o -E "\"[a-z0-9]{1,}\""`
	ID=`echo $ID | sed -e "s/\"//g" -e "s/p//g"`
	for myid in $ID
       	do
		echo "this is myid $myid"
		echo $TURL$myid >> "$DEST_DIR/filelist"
	done
}

function get_pics {
	echo "Will get pictures now. Please wait"
	cat "$DEST_DIR/filelist" | while read line ; do
		echo "Downloading $line"
		echo get tmpic wget
		wget $line -q -O /tmp/gel.html
		TMPIC=`cat /tmp/gel.html | grep -o -P "<img.*?\?"`

		TMPIC=`echo $TMPIC | grep -o -E "http.*\?"`
		TMPIC=`echo $TMPIC | sed -e "s/.$//g" -e "s/^5.//g"`
		echo get last wget
		cd $PICS_DIR
		wget "$TMPIC" 
		echo "-----Done!-----"
	done
	echo "----------All done!----------"
}

welcome
get_tags
get_urls
get_pics
exit 0


