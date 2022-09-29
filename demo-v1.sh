#!/usr/bin/env bash
MAGICK_OCL_DEVICE=true
NBROFFILES=600
FRAMERATE=600
rm -fr files  >/dev/null 2>&1
mkdir files >/dev/null 2>&1
echo "`date`: create test data set of $NBROFFILES files"
for FILENAME in `seq 1 $NBROFFILES `
do
	#cowsay "FILE $FILENAME" | tee files/${FILENAME}.txt
	dd if=/dev/random of=files/${FILENAME}.raw count=2 bs=1024
done
echo "`date`: Clean up system"
echo "Files"
ls -lrt files

rm -fr video  >/dev/null 2>&1
mkdir video >/dev/null 2>&1
rm -fr qrframespng  >/dev/null 2>&1
mkdir qrframespng >/dev/null 2>&1
rm -fr qrframessvg  >/dev/null 2>&1
mkdir qrframessvg >/dev/null 2>&1
rm -fr qrframes  >/dev/null 2>&1
mkdir qrframes >/dev/null 2>&1
rm -fr qrframesrestored 
mkdir qrframesrestored >/dev/null 2>&1
rm -fr restored  >/dev/null 2>&1
mkdir restored >/dev/null 2>&1
rm -fr uuencoded  >/dev/null 2>&1
mkdir uuencoded >/dev/null 2>&1
rm -fr uucoded  >/dev/null 2>&1
mkdir uuencoded >/dev/null 2>&1

echo "`date`: create qrcodes"
COUNT=0
BLK=0

for FILE in $(ls -1 files )
do
	NEWBLK=`echo $BLK |awk '{ print $1 + 1 }'`
	BLK=$NEWBLK
	cat files/$FILE  | uuencode $FILE | tee uuencoded/${COUNT} >/dev/null 2>&1
	qrencode -r uuencoded/${COUNT} -t PNG -o qrframes/frame${COUNT}.png
	NEWCOUNT=`echo $COUNT |awk '{ print $1 + 1 }'`
	COUNT=$NEWCOUNT
done
echo "`date`: Create mp4 video"
rm video/video.mp4 >/dev/null 2>&1

ffmpeg -f image2 -framerate $FRAMERATE -i qrframes/frame%d.png -c:v libx264 -crf 22 video/video.mp4 2>/dev/null

echo "`date`: Play video"
mplayer video/video.mp4  >/dev/null  2>/dev/null
echo "`date`: Create frames from mp4 video"
ffmpeg -i video/video.mp4 qrframesrestored/%04d.png >/dev/null 2>&1

for FILENAME in `ls -1 qrframesrestored`
do
	zbarimg  qrframesrestored/$FILENAME  > /tmp/test.txt 2>/dev/null
	sed -i "s/QR-Code://" /tmp/test.txt
	cd restored >/dev/null 2>&1
	uudecode /tmp/test.txt 2>/dev/null
	cd - >/dev/null
done


echo "Restored"
for file in `ls -1 restored`
do
	ls -l restored/$file
done

