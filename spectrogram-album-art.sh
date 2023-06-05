#!/bin/bash
# DEPENDENCIES
# ffmpeg
# mid3v2

# get more info about the file...
# https://stackoverflow.com/questions/43415353/explanation-of-audio-stat-using-sox
# TODO
# use custom frame to store processed status
# --TXXX "ALBUMARTISTSORT:Examples, The"
# --TPRC "SPEC_ALBUM_ART:true"

# https://linux.die.net/man/1/mid3v2
# mid3v2 -l ( list frames in file)

OIFS="$IFS"
IFS=$'\n'

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
specOut="$SCRIPTPATH/spectrogram.png"
specSoxOut="$SCRIPTPATH/spectrogram-sox.png"
inteOut="$SCRIPTPATH/intensity.png"
inteFlpOut="$SCRIPTPATH/intensity-flipped.png"
combOut="$SCRIPTPATH/combined.png"
ffmpegPath='ffmpeg'
count=0
procCount=0

setSpectrogram() {
	track=""
	album=""
  albumart=""
	artist=""
	processed=""
	printf "\n$1\n"
	dir=$(dirname "$1")
	dirn=${dir##*/}
	base="${1##*/}"
	basen="${base%.*}"

	# processed=$(/usr/bin/mid3v2 -l "$1"  | grep -a "TXXX=SPECPROC=" | cut -c15-)
	# if [ "$processed" != "1" ]
	if [ true ]
	then
		procCount=$(($procCount+1))
		printf "Processed count: $procCount\n"
    
    # ---- album art section ----
    # change to [ ! true ] to omit processing, just change metadata
    if [ true ]
    then
      channels=$(/usr/bin/soxi -c "$1")
      printf "ffmpeg - spectrogram\n"
      
      if [ $channels == '1' ]
      then
        $("$ffmpegPath" -y -hide_banner -loglevel error -i "$1" -lavfi showspectrumpic=s=600x600:mode=combined:fscale=log:start=100:stop=4000:legend=enabled:limit=-5:drange=25 "$specOut")
      else
        $("$ffmpegPath" -y -hide_banner -loglevel error -i "$1" -lavfi showspectrumpic=s=600x600:mode=separate:fscale=log:start=100:stop=4000:legend=disabled:limit=-5:drange=25:scale=log:gain=2 "$specOut")
      fi

      printf "ffmpeg - intensity\n"
      # ffmpeg intensity graph
      $("$ffmpegPath" -y -hide_banner -loglevel error -i "$1" -filter_complex "showwavespic=s=600x600:split_channels=1:colors=#ffffff" -frames:v 1 $inteOut)
      printf "ffmpeg - flip intensity\n"
      $("$ffmpegPath" -y -hide_banner -loglevel error -i $inteOut -filter_complex "vflip[flipped]" -map "[flipped]" -frames:v 1 $inteFlpOut)
      # ffmpeg overlay
      printf "ffmpeg - combine\n"
      $("$ffmpegPath" -y -hide_banner -loglevel error -i "$specOut" -i "$inteFlpOut" -filter_complex "[1:v]format=argb,geq=r='r(X,Y)':a='0.5*alpha(X,Y)'[zork]; [0:v][zork]overlay" "$combOut")
      
      printf "calling mid3v2\n"
      # deleting existing album art/setting new
      $(/usr/bin/mid3v2 --delete-frames="APIC" "$1")
      $(/usr/bin/mid3v2 -p "$combOut" "$1")
    fi
    # ---- album art section ----

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
    # albumart=$(/usr/bin/mid3v2 "$1" | grep ^TPE2= | cut -c6-)
    # printf "album artist: $albumart"
		album="$basen"
		artist="$dirn"
		
    $(/usr/bin/mid3v2 --album=$album --artist=$artist --TPE2 $artist "$1")
		    
		# setting processed metadata
		# $(/usr/bin/mid3v2 --TXXX "SPECPROC:1" $1)
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
