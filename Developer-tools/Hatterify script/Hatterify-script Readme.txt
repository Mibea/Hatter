
Hatterify creates Hatter Icons from Bitmap Images
-------------------------------------------------

This script converts square bitmap images into 128 × 128 SVG icons. It supports AVIF, PNG, WebP, JPG, and JPEG files.

For images with transparency, the script places the image inside a rounded, gradient-colored background. For opaque images, it crops the image to fill a rounded square. In both cases, it estimates a dominant color for the gradient and adds a soft shadow.
Requirements

Install these command-line tools and make sure they are available in your PATH:

    Bash
    heif-convert (for AVIF files)
    ImageMagick (magick)
    `base64
    `awk

The script uses mktemp and common Unix utilities such as mkdir, basename, mv, and ln.
Folder setup

making this script executable:

chmod +x Hatterify.sh

Run it from the directory where you want the following folders to be created:
text

IN/
OUT/
DONE/

Put the source images in IN/. The script creates OUT/ and DONE/ if they do not already exist.
Run the script
bash

./make-hatter-icons.sh

For every supported image in IN/, the script:

    Converts the image to a temporary PNG.
    Estimates its dominant color and calculates lighter and darker gradient colors.
    Creates a 128 × 128 SVG icon in OUT/.
    Moves the source image to DONE/.
    Removes the temporary file.

The generated SVG has the same base filename as the source image. For example, IN/example.png produces OUT/example.svg. If the filename is an app-id the script also creates a symlink in OUT/ named after the part following the final period.

Notes

    The input image should be square for the intended result. Opaque images are cropped to fill the icon; non-square images may lose part of their content.
    Transparent images are resized to fit within the icon while preserving their aspect ratio.
    Only files directly inside IN/ are processed; subfolders are not searched.
    Check OUT/ for the generated icons and DONE/ for the original images after processing.

