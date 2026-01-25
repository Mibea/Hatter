Hatter rounded gnome icons
======

Hatter is a rounded square icon theme for linux desktops. The main goal is to integrate well with the default Gnome desktop asthetics with rounded windows and buttons. The design philosophy is to create a rouded square theme that is faithfull to the application's identity, name and branding.

The second goal is to create a finished experience. I once heared the critisism that icon themes are a failed concept because you are constantly playing a game of whack-a-mole. And in a way that is true, especially with a theme like this one, any non square icon sticks out like a sore thumb. My idea to mitigate that is to create a lot of icons, this theme has at the time of writing 2675 unique app icons and 7000 linked app icons.

<img src="https://github.com/Mibea/Hatter/blob/2.0-Beta/Artwork/Hatter-overview.png" align="center" />


## Version 2.0 is radical different from the prevous versions of Hatter.

-Foremost, this is not a fork from Whitesur anymore.
-The directory structure is now based on the directory structure of Adwaita, the default Gnome icon theme, instead of Whitesur.
-Hatter-yaru is now a color variant instead of a full icon theme.
-the symbolic icons are now inherited from Adwaita instead of Whitesur, This choice was made for different reasons.
  
  1) It is much easier to maintain, so i can focus more time on the creation of App icons.
  2) The chance of Gnome updates breaking things is reduced significant.
  3) It stays consistent when missing icons are inherited from Adwaita.
  4) The old symbolic icons, tend to be less readable for some users.

-A full redesign of the folders
<img src="https://github.com/Mibea/Hatter/blob/2.0-Beta/Artwork/colors.png" align="center" />

There is also a KDE flavour with; 
  
  1) Bitmap app icons instead of SVG icons, 
  2) A file structure like Breeze,
  3) A light and dark theme.

Work to be done,

Making a Lightweight version for old systems.




## Important notice, when you update for the first time since version 2.0 delete all Hatter icon themes in your /home/*USER*/.local/share/icons folder 

Usage:  `./install.sh`



