# spectrogram-to-album-art
A script that generates a spectrogram of each audio file in a directory, then sets the album art to the spectrogram of the associated file.

Script file leverages a [custom build](http://jdesbonnet.blogspot.com/2014/02/sox-spectrogram-log-frequency-axis-and.html) of [sox](http://sox.sourceforge.net/sox.html) to generate spectrogram of file with logarithmic frequency scale. Spectrogram file is set to album artwork of audio file with [mid3v2](https://mutagen.readthedocs.io/en/latest/man/mid3v2.html).
If custom build is not available, omit the '-L' option from the sox command call. This will revert sox back to a linear frequency chart which decreases resolution at lower (100-1000Hz) freqencies but still makes a useful image.

# Ubuntu 20.04 Installation
Install necessary packages:  
`sudo apt-get install sox`  
`sudo apt-get install python3-mutagen`  

Build custom sox package:  
`sudo apt-get install build-essential fakeroot dpkg-dev`  
`mkdir sox-log-spectrogram`  
`cd sox-log-spectrogram`  
[download standard package source files](https://packages.ubuntu.com/focal/sox) into the build folder (dsc, tar.bz2 and tar.xz files from window on the right)  
`sudo apt-get install dpkg-dev`  
`dpkg-source -x sox_14.4.2+git20190427-2.dsc`
download modified spectrogram.c from [joe-desbonnet-blog](https://github.com/jdesbonnet/joe-desbonnet-blog/tree/master/projects/sox-log-spectrogram)  
replace ./sox-14.4.2.../src/spectrogram.c with 
`dpkg-buildpackage -rfakeroot -b`


# Usage
Make sure permissions allow for script to be ran as an executable.  
Script can be called in three different ways:
1. script can be ran with no arguments passed. It will recoursively scan all of the files in the folder in which it resides.  
e.g. `'/path/to/script/spectrogram_album_art.sh'`
2. A directory can be passed as an argrument when running the script.  
e.g. `'/path/to/script/spectrogram_album_art.sh '/path/to/files'`
3. An audio file can be passed as an argument when running the script.  
e.g. `'/path/to/script/spectrogram_album_art.sh '/path/to/files/file.mp3'`
