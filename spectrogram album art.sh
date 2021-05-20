#!/bin/bash
# https://ffmpeg.org/ffmpeg-filters.html#showspectrumpic
# ffmpeg -i '/mnt/pond/media/Plex Media/Other - Audio/google drive/Cock Hero/StLucifer/CH Levels 3.1 StL.mp3'
# -lavfi showspectrumpic=scale=sqrt:fscale=log:mode=combined:gain=0.10:size=2000x2000:start=25:stop=15000 waveform.png

# scale			lin, sqrt, cbrt, (log), 4thrt, 5thrt
# fscale		(lin), log
# saturation	(1), -10.0, 10.0
# win_func		‘rect’, ‘bartlett’, (‘hann’), ‘hanning’, ‘hamming’, ‘blackman’, ‘welch’, ‘flattop’, ‘bharris’, ‘bnuttall’, ‘bhann’, ‘sine’, ‘nuttall’, ‘lanczos’, ‘gauss’, ‘tukey’, ‘dolph’, ‘cauchy’, ‘parzen’, ‘poisson’, ‘bohman’
# mode			(combined), separate https://trac.ffmpeg.org/ticket/9061
# color			(intensity)
# gain			(1), 0.0, 1.0
# size			(4096x2048)
# start			(0)
# stop			(0)

# http://jdesbonnet.blogspot.com/2014/02/sox-spectrogram-log-frequency-axis-and.html

# get track name using eyeD3, if empty use file name, populate Album metadata with this info
# where to put existing album metadata? move to other location

# http://sox.sourceforge.net/sox.html
# https://www.mail-archive.com/sox-devel@lists.sourceforge.net/msg00769.html
OIFS="$IFS"
IFS=$'\n'

dirBase='/mnt/pond/media/Plex Media/Other - Audio/spectrogram.png'
for f in `find '/mnt/pond/media/Plex Media/Other - Audio' -type f -name "[!.]*"`
do
  # operations here
  #echo "file = $f"
  #echo $f
  dir=$(dirname "$f")
  #echo $dir
  base="${f##*/}"
  #echo $base
  basen="${base%.*}"
  printf "\nfile: $base\n"
  $(sox "$f" -n spectrogram -o "$dirBase" -L -R 80:8k -x 1050 -y 513 -z 50 -Z -20)
  sleep 1 
  printf "\ncalling eyeD3\n"
  $(/usr/bin/eyeD3 --add-image="$dirBase":FRONT_COVER "$f")
  sleep 1
  #rm "$dirBase"
done
