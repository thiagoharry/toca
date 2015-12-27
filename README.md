# toca.sh

Play music from a collection, optionally showing subtitles and helping to create subtitle files.

## Synopsis

**toca.sh**: *Play randomly musics from a collection stored in the directory referenced by the variable DIR_MUSICA in the script.*

**toca.sh FILE FILE ...**: *Play randomly all the music found in the given files or directories passed as argument.*

**toca.sh WORD**: *If WORD isn't a file, try to find musics or directories which has the word in its name and is stored inside the directory referenced by DIR_MUSICA inside the script. Plays randomly all the music found.*

**toca -l BASEFILE MUSIC_FILE**: *Helps creating a subtitle for a given music (see below).*

## Configuring

toca.sh (toca is 'play' in portuguese) is a very fast and simple shell script to play music.

Before using toca.sh, configure it changing the following variables in the first 11 lines of code:

* **TOCADOR**: Which command will be used to play the music. The default is "mplayer -noconsolecontrols"
* **FORMATOS**: The list of file extensions supported. The default is ".ogg .mp3 .mp4 .ogv"
* **DIR_MUSICA**: Where is your default music collection.

## Your Default Music Collection

Your default music collection should be any directory, where you should create some directory hierarchy to store your musics. A suggestion is creating one directory for each music genre, like:

* rock
* classic_music
* rap
* reggaeton

And inside each directory put one directory for each band or artist, like:

* iron_maiden
* rage_against_the_machine
* bach
* calle_13
* raul_seixas

And finally, inside each of this directory, put the name of some album, if applicable. For example:

* the_number_of_the_beast
* evil_empire
* residente_o_visitante

This way, if you use the command **toca.sh rock**, it ideally will play all your rock musics. And even if you type some incomplete name, like **toca.sh raul**, it would play all the musics in the directory raul_seixas.

## Creating a subtitle

First, choose a music to create the subtitle. Then, write in some file the music title in the first line and the lyrics in the next lines. You can put blank lines as you wish to mark the stanzas.

Next, let's say that you wrote the lyrics in the file 'subtitle.txt' and the music is 'music.mp3'. Now run the command:

> toca.sh -l subtitle.txt music.mp3

Now listen to the music and read the verses that appears in the screen. Each time the music plays the next verse not prefixed by a number, press ENTER. A number will prefix that verse, and then you wait for the next verse before pressing ENTER again.

After the end of the music, a hidden file named '.music.txt' will be created and next time the script plays that music, it will show subtitles in the screen. The file '.music.txt' can be edited or erased if you want to remove the subtitles. The format is very simple. Each non-empty line have a number followed by a verse. The number is how many seconds the music spends before playing that verse.
