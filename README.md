Wiki-Based-RPG
==============

A Text-Based RPG that will work with a Wiki of your choice! Mutliplayer only.

License:
This game is released under the "Do What The Fuck You Want To Public License":
/* This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://sam.zoy.org/wtfpl/COPYING for more details. */ 
If you do use the software, change it, add to it etc, then feel free to tell me about it either on github or indieDB.com.


How to Install
================
Download from GIT:
	Go to https://github.com/Germanunkol/Wiki-Based-RPG and click on the .zip button to download as a .zip file.

How to compile
================
To run the game, you need Löve2D, either installed or as a folder somewhere.
Get Löve2D from here: https://love2d.org/ (Love 0.8.0 was used to make the game, but later versions should work as well).
Linux: open a terminal cd to the directory where the game's main.lua is and type:
"love ."
This will open Löve and give the game folder as a command to it.
Windows/Mac: Open a console, enter the path to the love executable, then enter a space, then enter the path to folder in which the main.lua is. Press enter.

How to Play
================

How to mod
================

The game is open source. Modify as you wish.
To get you started, look at the first few lines in wikiClient.lua. Modyfing these lines will allow you to play the game with another Wiki. For example, you could play with the Minecraft wiki or a Star Trek wiki.
The lines starting with "local WIKI\_" are the ones to modify. Note that they are given in Lua pattern style, see a Lua string.find tutorial (or similar) for details. There are plenty on the web. The strings given here are all part of the page source. In firefox, you can navigate to a page and then press CTRL+U to get the page's source. Then look for constant parts in the source. For example, on Wikipedia, it seems all words that have multiple meanings will lead to a "disambiguation" site. On that site, there's always (accross all languages that I checked) a "disambig.svg" or similar. That's how the line:
_local WIKI_DISAMBIGUATION = "\[D,d\]isambig\[^\"\]*%.svg%.png"_ came to be.
