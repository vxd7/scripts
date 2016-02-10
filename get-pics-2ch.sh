#!/bin/bash

echo "Address"
read THREAD
wget -O /tmp/thread.html $THREAD
PICS=$(grep -E -o -e "/b/src/[a-zA-Z0-9/.]{1,}" /tmp/thread.html)
for item in $PICS ; do
	RESITEM="http://www.2ch.hk"${item}

	echo $RESITEM >> RES_1.txt
done

if [ -e RES.txt ]; then
	echo Adding new pics from the thread
	sort -u RES_1.txt >> RES_TMP.txt
	sort RES.txt RES_TMP.txt | uniq -u >> RES_ADD_PICS.txt
	rm RES_1.txt
	rm RES_TMP.txt
	echo "Added. Proceed downloading? [y/n]"
else
	echo Making pics list
	sort -u RES_1.txt >> RES.txt
	rm RES_1.txt
	echo Pictures list has been made successfully. Procees downloading?
fi
