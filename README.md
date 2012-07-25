Wiki-Based-RPG
==============

A Text-Based RPG that will work with a Wiki of your choice! Mutliplayer only.

License:
This game is released under the "Do What The Fuck You Want To Public License":  

> This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public License, Version 2, as published by Sam Hocevar. See
http://sam.zoy.org/wtfpl/COPYING for more details.

If you do use the software, change it, add to it etc, then feel free to tell me about it either on GitHub or IndieDB.com.


How to Install
================
###Download from GIT:###
Go to https://github.com/Germanunkol/Wiki-Based-RPG and click on the .zip button to download as a .zip file.

How to compile
================
To run the game, you need L&ouml;ve2D, either installed or as a folder somewhere.
Get L&ouml;ve2D from here: https://love2d.org/ (Love 0.8.0 was used to make the game, but later versions should work as well).
###Linux:###
Open a terminal cd to the directory where the game's main.lua is and type:

	love .

This will open L&ouml;ve and give the game folder as a command to it.
###Windows/Mac:###
Open a console, enter the path to the love executable, then enter a space, then enter the path to folder in which the main.lua is. Press enter. Example:

	C:\Program/ Files\Love\love.exe D:\Games\WB_RPG\

Optionally, you can pass the "--console" option to create a console so that the game can log to it (not needed on Linux).

	C:\Program/ Files\Love\love.exe D:\Games\WB_RPG\ --console

How to Play
================

###Main Idea###
The game is inspired by "Sleep is Death", a great game, where the story forms as you go along, and where the server creates a game for the client to play, in realtime.  
In the Wiki-Based-Role-Playing-Game, the server writes a story and the players reply by saying or doing things.
###Starting a server###
Simply click on "Start Server". Make sure to either forward/open port 8080 on your router, or use a service like Hamachi.
###Starting client###
Enter your Playername and the IP address of the server. If you're in the same LAN as the server, it often starts with "192.168.". If you're playing over the net, ask the server to visit a site like http://www.whatismyip.org/ and tell you their IP address. If you're playing via a service like Hamachi, make sure you're in the same network as the server, then click their name and get their IP Address (this one usually starts with "5.")
###Lobby###
At the beginning, while the clients are joining, the server chooses a word he/she would like the story to beginn with. The game then looks for a Wikipedia entry of that word (Make sure you're connected to the internet!). It will give you a choice of 5 words if there were multiple entires found.  
In the meantime, the players can create an avatar for themselves. They also need to write a sentence to describe their character, ideally fitting the theme which the server sets by choosing the Wiki word. To write this sentence, they need to enter a word, which is looked up on Wikipedia. Once the site is loaded in the background, words are randomly chosen for the player, from that page. The player then needs to pick one and use that word in his/her description. Example: if you enter "swimming", the wiki might give you the words: "Breaststroke", "Freestyle", "long course", "Snorkel" and "Summer Olympic Games". You can then write something like: "Germanunkol has never been to the Summer Olympic Games."
If you don't like the words the game chooses for you, at this point, you can retry by clicking on "Change description" and entering a new word.
###Game###
Once all players have created their avatar, chosen a description and have all clicked on "ready", the server can start the game. The first turn is the server's. He/She starts typing in the game window and writes the beginning of the story. He/She must use the wiki word previously chosen.  
Once the server has finished writing the first part of the story, the clients take turns to reply. If a client doesn't want to write anything this turn, he/she can write "/skip" and press enter to skip their  turn. Otherwise, you can write a text containing one or more commands. Note: per turn you can only write one text, but you can use multiple commands in this text. These are the available commands:

- /do TEXT
- /say TEXT
- /use inventoryID TEXT

####Example 1####
For example, if you have a key as the first Object in your inventory the following text:

	/say Let me check if I can open this... /do examines the chest. /use 1 chest's lock
	
will produce:

	Germanunkol: "Let me check if I can open this..."
	Germanunkol examines the chest.
	Germanunkol uses Key on chest's lock.
	
####Example 2####

	/do jumps. /say Look, I can jump higher than you! /do jumps even higher.
	
will produce:

	Germanunkol jumps.
	Germanunkol: "Look, I can jump higher than you!"
	Germanunkol jumps even higher.
	
Note that you do not need to add quotes when speaking, the game will add them for you.

While the clients are busy replying, the server can choose the next wiki word from the list. Optionally, he/she can put the object directly into the inventory of a client.
###Jokers###
The server has 3 Jokers which he/she can use to go back to one of the previous words, to get a new chance to take a different path.

###Hints on getting started###
- Use easy words to start with, like "chest" or "room"
- As a server, try not to dictate what players do. Let them choose as much as possible, write about what happens to them, not about what actions they take.
- Before choosing a word in the list of words, think about the concequences. If you choose "superconductor", you're not likely to get led back to a medivial theme.
- Because it can take a while for it to be your turn again, the game is ideal when doing something else at the same time. It is a VERY casual game. 

Report Bugs/Request features
================

If you find a bug, please tell me on indieDB or on Github. Please also let me know how to reproduce the bug.
If there's some feature you'd like to see in the game, drop me a line and I might implement it. If not, just implement it yourself!

How to mod
================

The game is open source. Modify as you wish. At this point, I should appologize for some pretty ugly code: This is the first larger project I have coded in love or lua.  
To get you started, look at the first few lines in wikiClient.lua. Modyfing these lines will allow you to play the game with another Wiki. For example, you could play with the Minecraft wiki or a Star Trek wiki.
The lines starting with "local WIKI\_" are the ones to modify. Note that they are given in Lua pattern style, see a Lua string.find tutorial (or similar) for details. There are plenty on the web. The strings given here are all part of the page source. In firefox, you can navigate to a page and then press CTRL+U to get the page's source. Then look for constant parts in the source. For example, on Wikipedia, it seems all words that have multiple meanings will lead to a "disambiguation" site. On that site, there's always (accross all languages that I checked) a "disambig.svg" or similar. That's how the line:
_local WIKI_DISAMBIGUATION = "\[D,d\]isambig\[^\"\]*%.svg%.png"_ came to be.
On windows, make sure to start the game with the --console option to get console output/debug output.
