<img src="https://github.com /> Hatter rouded gnome icons
======

Rounded square icon theme for linux desktops, Mainly Gnome on Fedora Workstation.
The goal of this theme is to create a rouded square theme that is faithfull to the application's identity, name and branding and not mimicking another program or operating system.

## Install tips

Usage:  `./install.sh`  **[OPTIONS...]**

|  OPTIONS:           | |
|:--------------------|:-------------|
|-d, --dest           | Specify theme destination directory (Default: $HOME/.local/share/icons)|
|-n, --name           | Specify theme name (Default: Hatter)|
|-b, --bold           | Install bold panel icons version|
|-r,--remove,-u,--uninstall | Uninstall (remove) icon themes|
|-h, --help           | Show this help|

> **Note for snaps:** To use these icons with snaps, the best way is to make a copy of the application's .desktop located in `/var/lib/snapd/desktop/applications/name-of-the-snap-application.desktop` into `$HOME/.local/share/applications/`. Then use any text editor and change the "Icon=" to "Icon=name-of-the-icon.svg"

> For more information, run: `./install.sh --help`

![alt](alt-version.png?raw=true)

![bold](bold-size.png?raw=true)

> Bold version suggested use in `High resolution display` like 4k display with 200% scale!

