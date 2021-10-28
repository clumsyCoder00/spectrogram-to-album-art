#!/bin/bash
# ---- **** ----
# DEPENDENCIES
# ffmpeg
# sox
# mid3v2
#
# ffmpeg -i '/mnt/pond/media/Plex Media/Other - Audio/PEP/PEP10 - estim.aac' '/mnt/pond/media/Plex Media/Other - Audio/PEP/PEP10 - estim.mp3'
# get more info about the file...
# https://stackoverflow.com/questions/43415353/explanation-of-audio-stat-using-sox
# TODO
# use custom frame to store processed status
# --TXXX "ALBUMARTISTSORT:Examples, The"
# --TPRC "SPEC_ALBUM_ART:true"

# https://linux.die.net/man/1/mid3v2
# mid3v2 -l ( list frames in file)
# 
# http://jdesbonnet.blogspot.com/2014/02/sox-spectrogram-log-frequency-axis-and.html

# http://webcache.googleusercontent.com/search?q=cache:DIoqGD6wbEcJ:sox.sourceforge.net/sox.html+&cd=1&hl=en&ct=clnk&gl=us
  # y in powers of 2+1
  # max plex resolution is 778 x 720
  # x = 2*y with stereo
  
  # sox --help-effect spectrogram
  
  # sox options
  # x		100-200000(800)		width of x axis in pixels
  # y							height of y axis in pixels
  # z		20-180(120)			Z-axis range in dB, sets range to be -num dBFS
  # Z							Z-axis upper limit in dBFS
  # q							Z-axis quantisation, number of different colors
  # m							monochrome spectrogram
  # h							Selects a high-colour palette - less visually pleasing than the 
  #									default colour palette, but it may make it easier to differentiate
  #									different levels. If this option is used in conjunction with −m, the
  #									result will be a hybrid monochrome/colour palette.
  # a							suppress the display of axis lines
  # r							supresss the display of axis and legends
  # t							image title text
  # c							bottom left text
  # o							output file, default to spectrogram.png
  
  # sox Statistics
  # n stat
  # n stats

# sox variables
# -R 80:8k -z 30 -Z -15

# plex artwork ratio 780:720 1.08:1 
# with legend and axis
# -x 212 -y 257
# -x 525 -y 257 (equates to 515 wide

# 525/270 * 780 = 570/2 = 285

OIFS="$IFS"
IFS=$'\n'

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
specOut="$SCRIPTPATH/spectrogram.png"
inteOut="$SCRIPTPATH/intensity.png"
combOut="$SCRIPTPATH/combined.png"
soxPath='/home/nuthanael/sox-log-spectrogram/sox-14.4.2+git20190427/src/sox'
ffmpegPath='ffmpeg'
count=0
procCount=0

setSpectrogram() {
	track=""
	album=""
	processed=""
	printf "\n$1\n"
	dir=$(dirname "$1")
	dirn=${dir##*/}
	base="${1##*/}"
	basen="${base%.*}"
	processed=$(/usr/bin/mid3v2 -l "$1"  | grep -a "TXXX=SPECPROC=" | cut -c15-)
	#if [ "$processed" != "1" ]
	if [ true ]
	then
		procCount=$(($procCount+1))
		printf "Processed count: $procCount\n"
		channels=$(/usr/bin/soxi -c "$1")
		printf "calling sox\n"
		
		if [ $channels == '1' ]
		then
			$("$soxPath" "$1" -V2 -n spectrogram -o "$specOut" -r -x 600 -y 600 -L -R 100:4k -z 25 -Z -5 -t 'MONO V3.0')
		else
			$("$soxPath" "$1" -V2 -n spectrogram -o "$specOut" -r -x 600 -y 300 -L -R 100:4k -z 25 -Z -5 -t 'STEREO V3.0')
		fi
		#sleep 1
		printf "calling ffmpeg\n"
		# ffmpeg intensity graph
		$("$ffmpegPath" -y -hide_banner -loglevel error -i "$1" -filter_complex "showwavespic=s=600x600:split_channels=1:colors=#ffffff" -frames:v 1 $inteOut)
		# ffmpeg overlay
		$("$ffmpegPath" -y -hide_banner -loglevel error -i "$specOut" -i "$inteOut" -filter_complex "[1:v]format=argb,geq=r='r(X,Y)':a='0.5*alpha(X,Y)'[zork]; [0:v][zork]overlay" "$combOut")
		
		printf "calling mid3v2\n"
		# deleting existing album art/setting new
		$(/usr/bin/mid3v2 --delete-frames="APIC" "$1")
		$(/usr/bin/mid3v2 -p "$combOut" "$1")

		# set album info
		# getting existing album info
		# track=$(/usr/bin/mid3v2 "$1" | grep ^TIT2= | cut -c6-)
		# if [ -z "$track" ]
		# then
		# 	printf "Track metadata is empty, using file name\n"
		# 	BASENAME="${1##*/}"
		# 	track="${BASENAME%.*}"
		# fi
		# album=$(/usr/bin/mid3v2 "$1" | grep ^TALB= | cut -c6-)
		# if [ "$album" != "$track" ]
		# then
		# 	printf "Setting track to album\n"
		# 	$(/usr/bin/mid3v2 --album=$track "$1")
		# fi
		album="$dirn - $basen"
		$(/usr/bin/mid3v2 --album=$album  "$1")
		
		# setting processed metadata
		$(/usr/bin/mid3v2 --TXXX "SPECPROC:1" $1)
		printf "finished\n"
	else
		printf "skipping\n"
	fi
	#sleep 1
}

if [ -n "$1" ]
then
	if [ -d $1 ]
	then
		for f in `find "$1" -type f \( -iname '*.mp3' -o -iname '*.wav' -o -iname '*.flac' \) -and -name "[!.]*"`
		do
			count=$(($count+1))
			printf "\ncount: $count"
			setSpectrogram "$f"
		done
	elif [ -f $1 ]
	then
		setSpectrogram "$1"
	else
		echo "$1 is not valid"
		exit 1
	fi
else
	for f in `find "$SCRIPTPATH" -type f \( -iname '*.mp3' -o -iname '*.wav' -o -iname '*.flac' \) -and -name "[!.]*"`
	do
		count=$(($count+1))
		printf "\ncount: $count"
		setSpectrogram "$f"
	done
fi
