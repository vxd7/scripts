#!/bin/bash
#Script for preserving the timestaamps of the directory and all subdirectories after modification
#Must be run twice -- before and after modification, to store all the timestamps and to restore them
DIR=$(dirname $0)
TFILE="${DIR}/.timestamps"

create-timestamps()
{
	#DList all files
	for file in $( find $(pwd) -type f ) 
	do
		echo "${file}" >> ${TFILE}
		TSTAMP=$(stat --printf %Y $file)
		echo "${TSTAMP}" >> ${TFILE}
	done
	TSTAMP=""
	#And directories respectively
	for file in $( find $(pwd) -type d ) 
	do
		echo "${file}" >> ${TFILE}
		TSTAMP=$(stat --printf %Y $file)
		echo "${TSTAMP}" >> ${TFILE}
	done
	TSTAMP=""
}

restore-timestamps()
{
	echo "Restore? [y/N]"
	read ANS
	if [[ $ANS != "y" ]]; then
		echo "Stopping"
		exit 0
	fi
	echo "Proceeding restore of timestamps"

	while read fileline
	do
		file=${fileline} #Read filename
		read fileline
		TSTAMP=${fileline} #Read it's timestamp  on the next line
		touch -d "@${TSTAMP}" "${file}" #And finally restore the orig timestamp
	done < ${TFILE}
	rm ${TFILE}

	echo "All done"
}

if [ ! -f $TFILE ]; then
	touch $TFILE
	create-timestamps
else
	restore-timestamps
fi


