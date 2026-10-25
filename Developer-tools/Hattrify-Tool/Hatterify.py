#!/usr/bin/env python3
# Hatterify
# Written by Emmanuel Aerssens
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

import gi
import os
import shutil
import subprocess
import tempfile
import base64

gi.require_version("Gtk", "4.0")
gi.require_version("Gdk", "4.0")

from gi.repository import (
    Gtk,
    Gdk,
    Gio,
    GLib
)

SUPPORTED = (".png", ".jpg", ".jpeg", ".webp", ".avif")

APP_DIR = os.path.join(
    os.path.expanduser("~"),
    ".local",
    "share",
    "Hatterify"
)

IN_DIR = os.path.join(APP_DIR, "IN")

PICTURES_DIR = GLib.get_user_special_dir(
    GLib.UserDirectory.DIRECTORY_PICTURES
)

EXPORT_DIR = os.path.join(
    PICTURES_DIR,
    "Hatterified Icons"
)

# legacy solution
#OUT_DIR = os.path.join(APP_DIR, "OUT")
#DONE_DIR = os.path.join(APP_DIR, "DONE")

def generate_icons():
    os.makedirs(EXPORT_DIR, exist_ok=True)
#    os.makedirs(DONE_DIR, exist_ok=True)

    for filename in os.listdir(IN_DIR):

        source_file = os.path.join(IN_DIR, filename)

        if not os.path.isfile(source_file):
            continue

        ext = os.path.splitext(filename)[1].lower()

        if ext not in (
            ".avif",
            ".png",
            ".webp",
            ".jpg",
            ".jpeg"
        ):
            continue

        base = os.path.splitext(filename)[0]

        svg = os.path.join(
            EXPORT_DIR,
            f"{base}.svg"
        )

        if os.path.exists(svg):
            os.remove(source_file)
 #               )
 #           )
            continue

        with tempfile.NamedTemporaryFile(
            suffix=".png",
            delete=False
        ) as tmp:

            tmp_png = tmp.name

        try:

            #
            # Convert naar PNG
            #
            if ext == ".avif":

                subprocess.run(
                    [
                        "heif-convert",
                        source_file,
                        tmp_png
                    ],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                    check=True
                )

            else:

                subprocess.run(
                    [
                        "magick",
                        source_file,
                        tmp_png
                    ],
                    check=True
                )

            #
            # Dominante kleur
            #
            dominant = subprocess.check_output(
                [
                    "magick",
                    tmp_png,
                    "-background",
                    "none",
                    "-trim",
                    "+repage",
                    "-resize",
                    "32x32",
                    "-scale",
                    "1x1!",
                    "-format",
                    "#%[hex:p{0,0}]",
                    "info:"
                ],
                text=True
            ).strip()

            if not dominant:
                dominant = "#808080"

            r = int(dominant[1:3], 16)
            g = int(dominant[3:5], 16)
            b = int(dominant[5:7], 16)

            lr = r + (255 - r) * 40 // 100
            lg = g + (255 - g) * 40 // 100
            lb = b + (255 - b) * 40 // 100

            dr = r + (255 - r) * 20 // 100
            dg = g + (255 - g) * 20 // 100
            db = b + (255 - b) * 20 // 100

            light = f"#{lr:02X}{lg:02X}{lb:02X}"
            dark = f"#{dr:02X}{dg:02X}{db:02X}"

            alpha_mean = float(
                subprocess.check_output(
                    [
                        "magick",
                        tmp_png,
                        "-alpha",
                        "extract",
                        "-format",
                        "%[fx:mean]",
                        "info:"
                    ],
                    text=True
                ).strip()
            )

            #
            # Transparant?
            #
            if alpha_mean < 0.9:

                png_data = subprocess.check_output(
                    [
                        "magick",
                        tmp_png,
                        "-resize",
                        "96x96",
                        "-background",
                        "none",
                        "-gravity",
                        "center",
                        "-extent",
                        "96x96",
                        "png:-"
                    ]
                )

                b64 = base64.b64encode(
                    png_data
                ).decode()

                background = """
  <rect
      x="8"
      y="8"
      width="112"
      height="112"
      rx="26"
      ry="26"
      fill="url(#bg)"/>
"""

                image = f'''
  <image
      x="16"
      y="16"
      width="96"
      height="96"
      preserveAspectRatio="xMidYMid meet"
      xlink:href="data:image/png;base64,{b64}"/>
'''

            else:

                png_data = subprocess.check_output(
                    [
                        "magick",
                        tmp_png,
                        "-resize",
                        "112x112^",
                        "-gravity",
                        "center",
                        "-extent",
                        "112x112",
                        "png:-"
                    ]
                )

                b64 = base64.b64encode(
                    png_data
                ).decode()

                background = ""

                image = f'''
  <image
      x="8"
      y="8"
      width="112"
      height="112"
      preserveAspectRatio="xMidYMid slice"
      clip-path="url(#roundedClip)"
      xlink:href="data:image/png;base64,{b64}"/>
'''

            svg_content = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg
 width="128"
 height="128"
 viewBox="0 0 128 128"
 xmlns="http://www.w3.org/2000/svg"
 xmlns:xlink="http://www.w3.org/1999/xlink">

<defs>

<linearGradient
 id="bg"
 x1="0%"
 y1="0%"
 x2="0%"
 y2="100%">
 <stop offset="0%" stop-color="{light}"/>
 <stop offset="100%" stop-color="{dark}"/>
</linearGradient>

<filter
 id="shadow"
 x="-0.1"
 y="-0.1"
 width="1.2"
 height="1.2">
 <feGaussianBlur stdDeviation="2.24"/>
</filter>

<clipPath id="roundedClip">
 <rect
   x="8"
   y="8"
   width="112"
   height="112"
   rx="26"
   ry="26"/>
</clipPath>

</defs>

<rect
 x="8"
 y="10.624"
 width="112"
 height="112"
 rx="26"
 ry="26"
 fill="#000000"
 opacity="0.25"
 filter="url(#shadow)"/>

{background}

{image}

</svg>
'''

            with open(svg, "w") as f:
                f.write(svg_content)

            target = base.split(".")[-1]

            if target != base:

                link = os.path.join(
                    EXPORT_DIR,
                    f"{target}.svg"
                )

                if os.path.lexists(link):
                    os.remove(link)

                os.symlink(
                    f"{base}.svg",
                    link
                )

            os.remove(source_file)
#                )
#            )

        finally:

            if os.path.exists(tmp_png):
                os.remove(tmp_png)

class MainWindow(Gtk.ApplicationWindow):

    def __init__(self, app):
        super().__init__(application=app)

        self.files = []

        self.set_title("Hatterify")
        self.set_default_size(600, 900)

        main_box = Gtk.Box(
            orientation=Gtk.Orientation.VERTICAL,
            spacing=12
        )

        main_box.set_margin_top(12)
        main_box.set_margin_bottom(12)
        main_box.set_margin_start(12)
        main_box.set_margin_end(12)

        self.set_child(main_box)

        #
        # Tabel
        #
        self.grid = Gtk.Grid()
        self.grid.set_row_spacing(8)
        self.grid.set_column_spacing(20)
       

        source_header = Gtk.Label(label="Source   ")
        source_header.set_halign(Gtk.Align.CENTER)

        self.grid.attach(
            source_header,
            1, 0, 1, 1
        )

        self.grid.attach(
            Gtk.Label(label=""),
            2, 0, 1, 1
        )

        self.grid.attach(
            Gtk.Label(label="   Result"),
            3, 0, 1, 1
        )

        grid_box = Gtk.Box(
            orientation=Gtk.Orientation.VERTICAL
        )

        grid_box.set_halign(Gtk.Align.CENTER)

        grid_box.append(self.grid)

        scroll = Gtk.ScrolledWindow()
        scroll.set_vexpand(True)
        scroll.set_child(grid_box)

        main_box.append(scroll)

        #
        # Drag & Drop
        #
        drop_target = Gtk.DropTarget.new(
            Gdk.FileList,
            Gdk.DragAction.COPY
        )

        drop_target.connect(
            "drop",
            self.on_drop
        )

        scroll.add_controller(drop_target)

        #
        # Knoppen
        #
        button_box = Gtk.Box(
            orientation=Gtk.Orientation.HORIZONTAL,
            spacing=12
        )
        
        button_box.set_halign(Gtk.Align.CENTER)
        
        main_box.append(button_box)

        generate_button = Gtk.Button(
            label="Generate Icons"
        )

        generate_button.connect(
            "clicked",
            self.on_generate_clicked
        )

        button_box.append(generate_button)

        clear_button = Gtk.Button(
            label="Clear"
        )

        clear_button.connect(
            "clicked",
            self.on_clear_clicked
        )

        button_box.append(clear_button)
  

        #
        # Status
        #
        self.status = Gtk.Label(
            label="0 files loaded"
        )

        self.status.set_halign(Gtk.Align.CENTER)
        
        main_box.append(self.status)

    def rebuild_table(self):

        #
        # Oude rijen verwijderen
        #
        child = self.grid.get_first_child()

        while child:

            next_child = child.get_next_sibling()

            layout = self.grid.query_child(child)

            if layout and layout.row > 0:
                self.grid.remove(child)

            child = next_child

        #
        # Nieuwe rijen toevoegen
        #
        row = 1

        for path in self.files:

            source_box = Gtk.Box(
                orientation=Gtk.Orientation.VERTICAL,
                spacing=4
            )
            
            source_box.set_halign(Gtk.Align.CENTER)
            
            source = Gtk.Picture.new_for_file(
                Gio.File.new_for_path(path)
            )

            source.set_size_request(64, 64)
            source.set_content_fit(
                Gtk.ContentFit.CONTAIN
            )

            source_label = Gtk.Label(
                label=os.path.basename(path)
            )
# memocard1            
            source_label.set_wrap(True)
            source_label.set_justify(Gtk.Justification.CENTER)
# memocard1 end    
            source_label.set_wrap(True)

            source_box.append(source)
            source_box.append(source_label)

            arrow = Gtk.Label(label="→")
            arrow.set_halign(Gtk.Align.CENTER)
            
            result_box = Gtk.Box(
                orientation=Gtk.Orientation.VERTICAL,
                spacing=4
            )

            result_box.set_halign(Gtk.Align.CENTER)

            result = Gtk.Picture()
            result.set_size_request(64, 64)

            result_box.append(result)

            base = os.path.splitext(
                os.path.basename(path)
            )[0]

            svg_name = f"{base}.svg"

            svg_path = os.path.join(
                EXPORT_DIR,
                svg_name
            )

            if os.path.exists(svg_path):

                result.set_file(
                    Gio.File.new_for_path(svg_path)
                )

                result_label = Gtk.Label(
                    label=svg_name
                )

            else:

                result_label = Gtk.Label(
                    label=""
                )
#memocard2
            result_label.set_wrap(True)
            result_label.set_max_width_chars(18)
            result_label.set_justify(Gtk.Justification.CENTER)
#       
            result_label.set_wrap(True)
            result_label.set_max_width_chars(18)

            result_box.append(result_label)

            self.grid.attach(
                source_box,
                1,
                row,
                1,
                1
            )

            self.grid.attach(
                arrow,
                2,
                row,
                1,
                1
            )

            self.grid.attach(
                result_box,
                3,
                row,
                1,
                1
            )

            row += 1

    def on_drop(self, target, value, x, y):

        files = value.get_files()

        added = 0

        for file in files:

            path = file.get_path()

            if not path:
                continue

            ext = os.path.splitext(path)[1].lower()

            if ext not in SUPPORTED:
                continue

            if path in self.files:
                continue

            self.files.append(path)
            added += 1

        self.status.set_text(
            f"{len(self.files)} files loaded"
        )

        self.rebuild_table()

        return added > 0

    def on_clear_clicked(self, button):

        self.files.clear()

        self.status.set_text(
            "0 files loaded"
        )

        self.rebuild_table()

    def on_generate_clicked(self, button):

        if not self.files:

            self.status.set_text(
                "No files selected"
            )

            return

        try:

            os.makedirs(IN_DIR, exist_ok=True)

            for file in self.files:

                target = os.path.join(
                    IN_DIR,
                    os.path.basename(file)
                )

                shutil.copy2(
                    file,
                    target
                )

            generate_icons()


            self.rebuild_table()

            self.status.set_text(
                "Icons generated successfully"
            )

        except Exception as e:

            self.status.set_text(
                f"Error: {e}"
            )



class Hatterify(Gtk.Application):

    def __init__(self):
        super().__init__(
            application_id="be.hatter.Hatterify"
        )

    def do_activate(self):

        window = MainWindow(self)
        window.present()


app = Hatterify()
app.run()
