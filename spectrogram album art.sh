#!/bin/bash
# todo
# https://linux.die.net/man/1/mid3v2
# mid3v2 -l ( list frames in file)
# strip cover, album frames
# mid3v2 --delete-frames=TALB,APIC
# http://jdesbonnet.blogspot.com/2014/02/sox-spectrogram-log-frequency-axis-and.html

# http://webcache.googleusercontent.com/search?q=cache:DIoqGD6wbEcJ:sox.sourceforge.net/sox.html+&cd=1&hl=en&ct=clnk&gl=us
  # y in powers of 2+1
  # max plex resolution is 778 x 720
  # x = 2*y with stereo
  
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

OIFS="$IFS"
IFS=$'\n'

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
specOut="$SCRIPTPATH/spectrogram.png"

setSpectrogram() {
	  printf "\n$1\n"
	  dir=$(dirname "$1")
	  base="${1##*/}"
	  basen="${base%.*}"
	  printf "calling sox\n"
	  channels=$(/usr/bin/soxi -c "$1")
	  
	  if [ $channels == '1' ]
	  then
		$(sox "$1" -n spectrogram -o "$specOut" -t 'MONO V2.0' -L -R 80:8k -x 212 -y 257 -z 30 -Z -15)
	  else
		$(sox "$1" -n spectrogram -o "$specOut" -t 'STEREO V2.0' -L -R 80:8k -x 525 -y 257 -z 30 -Z -15)
	  fi
	  sleep 1
	  printf "calling mid3v2\n"
	  $(/usr/bin/mid3v2 --delete-frames=TALB,APIC "$1")
	  $(/usr/bin/mid3v2 -p "$specOut" "$1")
	  printf "finished $base\n"
	  sleep 1
}

if [ -n "$1" ]
then
	setSpectrogram "$1"
else
	for f in `find "$SCRIPTPATH" -type f \( -iname '*.mp3' -o -iname '*.wav' \) -and -name "[!.]*"`
	do
	setSpectrogram "$f"
	done
fi
