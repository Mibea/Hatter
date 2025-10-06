#!/bin/bash

# Force Zenity Status message box to always be on top.

(
# =================================================================
echo "# Downloading Hatter source" ; sleep 1
cd
# =================================================================
echo "10"
echo "# Downloading Hatter source" ; sleep 1
git clone https://github.com/Mibea/Hatter.git 
# =================================================================
echo "50"
echo "# Compiling the Hatter icon theme" ; sleep 1
cd Hatter
# =================================================================
echo "75"
echo "# Compiling the Hatter icon theme" ; sleep 1
(ZEN=$(zenity --question --title "Hatter update" --text "What theme do you want to update?" --switch --extra-button "Hatter" --extra-button "Hatter-yaru" --extra-button "Both")
for z in "${ZEN}"
do
   if [[ "${z}" == "Hatter" ]]
   then
   ./install.sh 
   elif [[ "${z}" == "Hatter-yaru" ]]
   then
   ./install.sh -t yaru
   elif [[ "${z}" == "Both" ]]
   then
   ( ./install.sh 
   ./install.sh -t yaru)
   fi
done)
# =================================================================
echo "80"
echo "# Cleaning up" ; sleep 1
cd
# =================================================================
echo "85"
echo "# Cleaning up" ; sleep 1
rm -rf Hatter
# =================================================================
echo "99"
echo "# Almost done" ; sleep 1
# notify-send 'Hatter Update' 'The Hatter icon theme is updated'
# =================================================================
echo "# All finished." ; sleep 1
echo "100"
) |
zenity --progress \
  --title="Hatter Update" \
  --text="Preparing" \
  --percentage=0 \
  --auto-close \
  --auto-kill


(( $? != 0 )) && zenity --error --text="Update failed!"



exit 0
