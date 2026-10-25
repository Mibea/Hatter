Hatterify-tool User Guide
--------------------

What Hatterify does

Hatterify turns image files into SVG icon files. It creates a rounded-square icon, adds a subtle shadow, and uses the image’s dominant color to make a background for images with transparency.

Supported input formats: PNG, JPG/JPEG, WebP, and AVIF.
Before you start

Hatterify requires Python with GTK 4 and PyGObject, plus these command-line tools:

    ImageMagick, available as `magick
    heif-convert, for AVIF files

Make sure these dependencies are installed and available on your system’s PATH. The program saves generated icons to the system’s Pictures folder, in a subfolder named Hatterified Icons.
Using Hatterify

    Launch Hatterify.
    Drag and drop one or more supported image files into the window. The table shows each source image and, when available, its generated icon.
    Click Generate Icons to create the icons.
    Find the resulting .svg files in Pictures/Hatterified Icons.
    Click Clear to remove the current file list from the window. This does not delete generated icons.

Output behavior

    Images with transparency are placed inside the rounded-square design, with a gradient background based on the image’s dominant color.
    Images without transparency are cropped to fill the rounded square.
    If an SVG with the same base filename already exists in the output folder, Hatterify skips that input and removes the copied input file from its processing folder.
    If a filename contains periods, Hatterify also creates a symbolic link using the text after the final period as its name. For example, logo.dark.png produces logo.dark.svg and may also create dark.svg.

Troubleshooting

    A file is not added: Check that it is a PNG, JPG/JPEG, WebP, or AVIF file.
    Generation fails: Check that ImageMagick is installed and that magick runs from a terminal. For AVIF files, also check that heif-convert is installed.
    No output appears: Look in the Hatterified Icons folder inside Pictures, and check whether an SVG with that filename already existed. Hatterify skips files when the matching SVG already exists.

