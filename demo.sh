#!/usr/bin/env bash
NBROFFILES=100
rm -fr files 
mkdir files >/dev/null 2>&1
for FILENAME in `seq 1 $NBROFFILES `
do
	echo $FILENAME
	cowsay "FILE $FILENAME" | tee files/${FILENAME}.txt
done

rm -fr video 
mkdir video >/dev/null 2>&1
rm -fr qrframes 
mkdir qrframes >/dev/null 2>&1
rm -fr qrframesrestored 
mkdir qrframesrestored >/dev/null 2>&1
rm -fr restored 
mkdir restored >/dev/null 2>&1
rm -fr uuencoded 
mkdir uuencoded >/dev/null 2>&1
rm -fr uucoded 
mkdir uuencoded >/dev/null 2>&1


COUNT=0

for FILE in $(ls -1 files )
do
	echo $FILE
	
	NEWCOUNT=`echo $COUNT |awk '{ print $1 + 1 }'`
	COUNT=$NEWCOUNT

	cat files/$FILE  | uuencode $FILE | tee uuencoded/$COUNT
	qrencode -r uuencoded/${COUNT}  -o qrframes/frame${COUNT}.png
done
rm video/video.mp4

ffmpeg -f image2 -framerate 60 -i qrframes/frame%d.png -c:v libx264 -crf 22 video/video.mp4
ffmpeg -i video/video.mp4 qrframesrestored/%04d.png 

for FILENAME in `ls -1 qrframesrestored`
do
	echo $FILENAME
	zbarimg  qrframesrestored/$FILENAME  > /tmp/test.txt
	sed -i "s/QR-Code://" /tmp/test.txt
	cd restored
	uudecode /tmp/test.txt
	cd -
done

ls -rlt restored
