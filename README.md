# Hatter Rounded GNOME Icons

![Hatter icons](https://github.com/Mibea/Hatter/blob/main/Developer-tools/Artwork/Hatter-overview.png)


## Design
Hatter is a rounded-square icon theme designed primarily for Adwaita, the default GNOME desktop theme. Its aesthetic complements GNOME’s rounded windows, buttons, and other interface elements.

The theme’s design philosophy is to create rounded-square icons that remain faithful to each application’s identity, name, color palette, and branding. Rather than replacing icons with generic alternatives or imitating another operating system, Hatter preserves the character of the original applications wherever possible.

## Coverage
A major goal is to provide a polished and complete desktop experience. Icon themes can easily become inconsistent when unsupported applications fall back to mismatched or non-square icons. Hatter addresses this by offering extensive application coverage. At the time of writing, the theme includes approximately 5,000 unique application icons and 12,400 linked application icons.

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

First build the icon theme

 <pre><code>./Build-Hatter.sh</code></pre>

Then run the installation script from the project directory. Use sudo to install the themes system-wide in /usr/share/icons; without sudo, the script installs them in your user icon directory.

 <pre><code>./Install-Hatter.sh</code></pre>

For a system-wide installation:

<pre><code>sudo ./Install-Hatter.sh</code></pre>

## Package

First build the icon theme

 <pre><code>./Build-Hatter.sh</code></pre>

Then run the packaging script from the project directory:

 <pre><code>./Package-Hatter.sh</code></pre>

It creates Hatter-kde.zip from folders whose names contain kde, and Hatter.zip from the other folders. The ZIP files are placed in the user's Downloads folder. After both archives are created successfully, the script deletes the Build directory.
