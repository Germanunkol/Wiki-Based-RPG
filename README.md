Wiki-Based-RPG
==============

A Text-Based RPG that will work with a Wiki of your choice! Mutliplayer only.

License:
This game is released under the "Do What The Fuck You Want To Public License":  

	This program is free software. It comes without any warranty, to
	the extent permitted by applicable law. You can redistribute it
	and/or modify it under the terms of the Do What The Fuck You Want
	To Public License, Version 2, as published by Sam Hocevar. See
	http://sam.zoy.org/wtfpl/COPYING for more details.

If you do use the software, change it, add to it etc, then feel free to tell me about it either on github.com or IndieDB.com.


How to Install and Run
================
Getting the game to run should be fairly simple, but there are many ways to do so.
###Linux and Mac###
1.	Download the .love file from http://www.indiedb.com/games/wiki-based-rpg/downloads
2.	Install L&ouml;ve2D, either from your repositories (version 0.8.0 and up recommended!) or from https://love2d.org
3.	Open a commmand line/terminal and type:

		love /path/to/WikiBasedRPG.love
		
Note: For special characters to work correctly, you need a version later than 0.8.0. At the time of writing, the current stable version is 0.8.0, so you might need to compile L&ouml;ve2d yourself. For instructions, see the L&ouml;ve Website.

###Windows###
1. Get the .exe file from http://www.indiedb.com/games/wiki-based-rpg/downloads
2. Double-click the file -> play!

Alternatively:
1. Get the .love file from http://www.indiedb.com/games/wiki-based-rpg/downloads
2. Download and install L&ouml;ve2D from https://love2d.org/ (version 0.8.0 and up recommended!
3. Start the program cmd.exe (either start->type cmd->press enter or start->run->cmd.exe->enter). Then run:

		Path\To\love.exe Path\To\WikiBasedRPG.love

How to Play
================

###Main Idea###
The game is inspired by "Sleep is Death", a great game, where the story forms as you go along, and where the server creates a game for the client to play, in realtime.  
In the Wiki-Based-Role-Playing-Game, the server writes a story and the players reply by saying or doing things. The story is repeatedly influenced by words that are taken automatically from Wikipedia entries.
###Starting a server###
Simply click on "Start Server". **If you want to play over the internet, make sure to either forward/open port 8080 on your router, or use a service like Hamachi.** Only the server has to port-forward, client's shouldn't need to.
###Starting client###
Enter your Playername and the IP address of the server. If you're in the same LAN as the server, it often starts with "192.168.". If you're playing over the net, ask the server to visit a site like http://www.whatismyip.org/ and tell you their IP address. If you're playing via a service like Hamachi, make sure you're in the same network as the server, then click their name and get their IP Address (this one usually starts with "5.")
###Lobby###
At the beginning, while the clients are joining, the server chooses a word he/she would like the story to beginn with. The game then looks for a Wikipedia entry of that word (Make sure you're connected to the internet!). It will give you a choice of 5 words if there were multiple entires found.  
In the meantime, the players can create an avatar for themselves. They also need to write a sentence to describe their character, ideally fitting the theme which the server sets by choosing the Wiki word. To write this sentence, they need to enter a word, which is looked up on Wikipedia. Once the site is loaded in the background, words are randomly chosen for the player, from that page. The player then needs to pick one and use that word in his/her description. Example: if you enter "swimming", the wiki might give you the words: "Breaststroke", "Freestyle", "long course", "Snorkel" and "Summer Olympic Games". You can then write something like: "Germanunkol has never been to the Summer Olympic Games."
If you don't like the words the game chooses for you, at this point, you can retry by clicking on "Change description" and entering a new word.
Optionally, the server can choose a theme which suits the story he or she has in mind.
###Game###
Once all players have created their avatar, chosen a description and have all clicked on "ready", the server can start the game. The first turn is the server's. He/She starts typing in the game window and writes the beginning of the story. He/She must use the wiki word previously chosen.  
Once the server has finished writing the first part of the story, the clients take turns to reply. If a client doesn't want to write anything this round, he/she can write "/skip" and press enter to skip their  turn. Otherwise, you can write a text containing one or more commands. Note: per turn you can only write one text, but you can use multiple commands in this text. These are the available commands:

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

While the clients are busy replying, the server can choose the next wiki word from the list. Optionally, he/she can put a object/word directly into the inventory of a client.
As of version 0.6, there's a chance that instead of the Storyteller choosing a word, one of the clients gets to choose it for him.
###Jokers###
The server has 3 Jokers which he/she can use to go back to one of the previous words, to get a new chance to take a different path.

###Hints on getting started###
- Use easy words to start with, like "treasure" or "room"
- As a server, try not to dictate what players do. Let them choose as much as possible, write about what happens to them, not about what actions they take.
- Before choosing a word in the list of words, think about the concequences. If you choose "superconductor", you're not likely to get led back to a medivial theme.
- Because it can take a while for it to be your turn again, the game is ideal when doing something else at the same time. It is a VERY casual game.
- Players should not just invent and use random objects. Only use what the server gives to you!

###Exporting to .html###
Clicking the export button will create a .html file. It will be written in the following directories:

- Windows XP: C:\Documents and Settings\user\Application Data\Love\WikiBasedRPG or %appdata%\Love\WikiBasedRPG
- Windows Vista and 7: C:\Users\user\AppData\Roaming\LOVE\WikiBasedRPG or %appdata%\Love\WikiBasedRPG
- Linux: $XDG_DATA_HOME/love/ or ~/.local/share/love/WikiBasedRPG
- Mac: /Users/user/Library/Application Support/LOVE/WikiBasedRPG

Make sure to send me your stories on IndieDB or github, so I can post them!

Report Bugs/Request features
================
If you find a bug, please tell me on indieDB or on Github. Please also let me know how to reproduce the bug.  
If there's some feature you'd like to see in the game, drop me a line and I might implement it. Or, even better: just implement it yourself!

Run from source:
================
If you have downloaded the .love file from IndieDB, you already have the source code. The .love is a renamed .zip file, which you can rename back to .zip and then extract anywhere you wish.  
Alternatively, get the current source code from git: https://github.com/Germanunkol/Wiki-Based-RPG  
Windows users: the .exe is also a compressed file. To get to the data, uncompress it using a zip Program like 7zip (might also work with the windows standard zip Program).

**(NOTE: as of Wiki-Based-RPG version 0.6, you can get secial character to work if you run a L&ouml;ve version higher than 0.8.0. At the time of writing, the current version is 0.8.0, so for getting special characters to work, you need to compile l&ouml;ve from source. Check its website for details on how to do this.)**

###Linux:###

1. Install L&ouml;ve2D, either from your repositories (version 0.8.0 and up recommended!) or from https://love2d.org/ 
2. Open a terminal, cd to the directory where the game's main.lua is and type:

		love .

This will open L&ouml;ve and give the game folder as a command to it.
###Windows/Mac:###
Open a console, enter the path to the love executable, then enter a space, then enter the path to folder in which the main.lua is. Press enter. Example:

		"C:\Program Files\Love\love.exe" D:\Games\WB_RPG\

Optionally, you can pass the "--console" option to create a console so that the game can log to it (not needed on Linux).

		"C:\Program Files\Love\love.exe" D:\Games\WB_RPG\ --console

How to mod
================

The game is open source. Modify as you wish. At this point, I should appologize for some pretty ugly code: This is the first larger project I have coded in love or lua. I DO need to add more comments, as well.  
Get the code from github, or extract the .love or .zip file you have downloaded. (.exe can also be extracted to get you to the code).
On windows, make sure to start the game with the --console option to get console output/debug output.
Also start the game with the --debug option so that there is more output.

**If you translate the game or add another wiki or create a new cool theme, make sure to send them to me via github or indieDB! I'd be very happy to add them to the next version!**

###Change Wikipedia###
To get you started, look at the first few lines in wikiClient.lua. Modyfing these lines will allow you to play the game with another Wiki. For example, you could play with the Minecraft wiki or a Star Trek wiki. Or you could try using another language's Wikipedia or try http://simple.wikipedia.org  
The lines starting with "local WIKI\_" are the ones to modify. Note that they are given in Lua pattern style, see a Lua string.find tutorial (or similar) for details. There are plenty on the web. The strings given here are all part of the page source. In firefox, you can navigate to a page and then press CTRL+U to get the page's source. Then look for constant parts in the source. For example, on Wikipedia, it seems all words that have multiple meanings will lead to a "disambiguation" site. On that site, there's always (accross all languages that I checked) a "disambig.svg" or similar.  
That's how the line:  
_local WIKI_DISAMBIGUATION = "\[D,d\]isambig\[^\"\]*%.svg%.png"_  
came to be.

###Translate###
Wiki-Based-RPG is very easy to translate: In the Languages Folder, there is file called English.txt. Duplicate it (Copy and Paste), rename it to [YourLanguage].txt, open it in your favourite text editor and start translating the strings inside the quare brackets. For an example, see Deutsch.txt.
Note:

- To get the language to be shown at the beginning of your game, simply create an image called [YourLanguage].png in /Images/Flags (Must be named exactly the same as the language, except for the file ending) which shows the flag of country you're translating for. The image should be about 50 px by 33 px. Now, when you start the game, it automatically loads your language.
- Many languages have special characters. To get them to work, you need a l&ouml;ve version greater than 0.8.0 (otherwise they will not be recognized by the game). See "Run from source" on how to get that version (at the time of this writing, 0.8.0 is the latest stable release, so you'd need to compile it from source. Which is pretty easy, though).
- To make sure the game recognizes the special characters, inside [YourLanguage].txt, you need to add them into the SPECIAL_CHARACTERS list. To do that: Run the game using the --debug option from the consol e. Example:  

	- Linux: /path/to/love /path/to/game/folder --debug
	- Windows: \path\to\love.exe \path\to\game\folder --console --debug  
Then simply press the keys and you'll see the unicode representations of them in the console. Open the [YourLanguage].txt and add the line: SPECIAL_CHARACTERS[UNICODE] = "CHARACTER", where CHARACTER is the character you want to be able to use and UNICODE is the number representing. Again, for examples, see Deutsch.txt.
- Make sure to change the WIKI_URL as well. If you leave it as en.wikipedia.org, your game will work in your new language, but still use the same english wiki version.
	
###Make Your Theme###
Wiki-Based-RPG is now more colourful! Yay!  
Making a theme is very simple. What you need to know:

- The game automatically loads all recognized themes. No need to mess with code 'n stuff.
- The game recognizes themes by checking for Folders inside the /Theme subdirectory. If there is a ThemeSettings.txt inside one of those folders, the folder is recognized as a theme.

Copy and paste the Standard folder inside the Themes folder. Inside the new folder, open the ThemeSettings.txt and edit the colours to your liking.  
To add images to your theme, simply create the image and place it inside the folder. The game will automatically place the images at the right spot if you name the image correctly. Available names are:

- Top_Left.png
- Top_Center.png
- Top_Right.png
- Left.png
- Right.png
- Bottom_Left.png
- Bottom_Center.png
- Bottom_Right.png
- Inventory.png
- Chat.png
- Game.png

Images should not be too distracting, the text rendered over them still needs to be readable. They should also not be much bigger than 300*300 pixels.  
Happy Modding!
