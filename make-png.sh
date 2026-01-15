#!/usr/bin/env bash

rm Hatter/16x16/places/*.png
cp Hatter/scalable/places/*.svg Hatter/16x16/places 
inkscape Hatter/16x16/places/*.svg --export-type=png --export-width=32
rm Hatter/16x16/places/*.svg

rm Hatter/16x16/mimetypes/*.png
cp Hatter/scalable/mimetypes/*.svg Hatter/16x16/mimetypes 
inkscape Hatter/16x16/mimetypes/*.svg --export-type=png --export-width=32
rm Hatter/16x16/mimetypes/*.svg

rm -r Hatter-png
cp -r Hatter Hatter-png
inkscape Hatter-png/scalable/apps/*.svg --export-type=png --export-width=128
inkscape Hatter-png/scalable/devices/*.svg --export-type=png --export-width=128
inkscape Hatter-png/scalable/mimetypes/*.svg --export-type=png --export-width=128
inkscape Hatter-png/scalable/places/*.svg --export-type=png --export-width=128
inkscape Hatter-png/scalable/status/*.svg --export-type=png --export-width=128
rm Hatter-png/scalable/apps/*.svg
rm Hatter-png/scalable/devices/*.svg
rm Hatter-png/scalable/mimetypes/*.svg
rm Hatter-png/scalable/places/*.svg
rm Hatter-png/scalable/status/*.svg

  

  

