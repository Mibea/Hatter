# Hatter Rounded GNOME Icons

![Hatter icons](https://github.com/Mibea/Hatter/blob/main/Developer-tools/Artwork/Hatter-overview.png)


## Design
Hatter is a rounded-square icon theme designed primarily for Adwaita, the default GNOME desktop theme. Its aesthetic complements GNOME’s rounded windows, buttons, and other interface elements.

The theme’s design philosophy is to create rounded-square icons that remain faithful to each application’s identity, name, color palette, and branding. Rather than replacing icons with generic alternatives or imitating another operating system, Hatter preserves the character of the original applications wherever possible.

## Coverage
A major goal is to provide a polished and complete desktop experience. Icon themes can easily become inconsistent when unsupported applications fall back to mismatched or non-square icons. Hatter addresses this by offering extensive application coverage. At the time of writing, the theme includes approximately 4,800 unique application icons and 12,400 linked application icons.

|Hatter currently covers:|
|:------- |
|99% of Flatpak applications|
|The 100 highest-rated native Linux games on Steam|
|Many of the most popular non-native Steam games|
|Folders, MIME types, devices, maps, and other desktop elements|

|Particular attention is given to:|
|:------- |
|Core GNOME applications|
|GNOME Circle applications|
|Popular applications such as GIMP, Inkscape, LibreOffice, and Steam|

## Other desktop environments

Hatter is designed primarily for GNOME, so most development and testing focuses on providing the best possible experience on that desktop environment. A separate edition is available for KDE, although it receives less frequent attention.

### Testing
Hatter is used daily on Fedora Workstation and tested on other distributions several times a year.

### Testing experiences.

| GNOME (on Fedora) |
| :------- |
| This is where Hatter integrates best and feels most at home. |


| KDE (on Fedora KDE)|
| :------- |
| Hatter-kde works well overall, but it is not completely flawless.|
| The standard Hatter edition is not a great experience. |
| The default KDE theme and the hatter icon theme do not combine well visually. |


| Cinnamon (on Linux Mint) |
| :------- |
| The standard Hatter edition works very well with Cinnamon|

## Install


Then run the installation script from the project directory. Use sudo to install the themes system-wide in /usr/share/icons; without sudo, the script installs them in your user icon directory.

<pre><code>./Install.sh</code></pre>

You will be presented with an interactive menu.
1) Hatter only\n'
2) Hatter + colour variants\n'
3) Hatter + Yaru colour variants\n'
4) Hatter + colour variants + Yaru colour variants\n'
5) Hatter-kde + Hatter-kde-dark\n'
6) Everything\n\n' 

Passing the number as an argument skips the interactive menu.

<pre><code>./install.sh [1-6]</code></pre>

For a system-wide installation:

<pre><code>sudo ./install.sh</code></pre>


## Build

Build the icon theme without installing it

### Usage: build.sh [OPTIONS] [TARGET...]

Generates Hatter icon themes into a destination directory.

Targets (at least one target or --all is required, unless --list is used):
  Hatter          the base theme
  colours         all colour variants (Hatter-Blue ... Hatter-Yellow)
  yaru            all Yaru colour variants (Hatter-Yaru-Blue ... Hatter-Yaru-Yellow)
  kde             Hatter-kde and Hatter-kde-dark
  all             everything (same as --all)
  <theme-name>    any single theme, e.g. Hatter-Red or Hatter-Yaru-Teal

Options:
  -d, --dest DIR        output directory (default: ./dist, relative to the
                        directory you run the script from)
  -a, --all             build everything
      --clean-all       first remove every known Hatter theme from DIR,
                        not only the ones that are about to be built
      --version VER     write a VERSION file with VER into every built theme
      --whitespace MODE what to do with file names containing whitespace:
                        warn (default), fail, or ignore
      --list            only print the theme names that the given targets
                        resolve to (all themes if no target is given), then exit
  -h, --help            show this help

Examples:

   <pre><code>./build.sh --all --dest /tmp/out</code></pre>

   <pre><code>./build.sh Hatter colours --dest "$HOME/.local/share/icons"</code></pre>

   <pre><code>./build.sh Hatter-Red Hatter-Yaru-Red --version 1.4.0</code></pre>

