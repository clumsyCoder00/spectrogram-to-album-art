#!/bin/bash

# http://jdesbonnet.blogspot.com/2014/02/sox-spectrogram-log-frequency-axis-and.html

# https://linux.die.net/man/1/sox
  # y in powers of 2+1
  # max plex resolution is 778 x 720
  # x = 2*y with stereo
OIFS="$IFS"
IFS=$'\n'

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
specOut="$SCRIPTPATH/spectrogram.png"

#-------------- HELPER ---------------
setSpectrogram() {
	  printf "\n$1\n"
	  dir=$(dirname "$1")
	  base="${1##*/}"
	  basen="${base%.*}"
	  printf "calling sox\n"
	  channels=$(/usr/bin/soxi -c "$1")
	  
	  if [ $channels == '1' ]
	  then
		$(sox "$1" -n spectrogram -o "$specOut" -t MONO -L -R 80:8k -x 212 -y 257 -z 30 -Z -15)
	  else
		$(sox "$1" -n spectrogram -o "$specOut" -t STEREO -L -R 80:8k -x 525 -y 257 -z 30 -Z -15)
	  fi
	  sleep 1
	  printf "calling mid3v2\n"
	  $(/usr/bin/mid3v2 -p "$specOut" "$1")
	  printf "finished $base\n"
	  sleep 1
}
#---------- END HELPER ----------------

if [ -n "$1" ]
then
	setSpectrogram "$1"
else
	for f in `find "$SCRIPTPATH" -type f \( -iname '*.mp3' -o -iname '*.wav' \) -and -name "[!.]*"`
	do
	setSpectrogram "$f"
	done
fi
