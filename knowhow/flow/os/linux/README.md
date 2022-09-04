# Linux OS

Terminal
Select text then MMB to paste.

## How to register new mimetypes. (like "project.godot" files)
![Associating Mimetype](docs/godot_mimetype.png)

1. Find the locations of the app and the icon.
1. Edit the following lines in the **"godot.desktop"** file to use the _absolute file path_ to the application:
 - Exec=**/home/unblinky/apps/godot/godot -f**
 - Icon=**/home/unblinky/apps/godot/godot.svg**
 - MimeType=application/x-godot-project;application/x-godot;

```
[Desktop Entry]
Name=Godot
GenericName=Game Engine
Comment=2D & 3D game engine
Keywords=3d;cg;modeling;animation;painting;texturing;rendering;render engine;game engine;cgscript;
Exec=/home/unblinky/apps/godot/godot -f
Icon=/home/unblinky/apps/godot/godot.svg
Terminal=false
Type=Application
Categories=Graphics;3DGraphics;
MimeType=application/x-godot-project;application/x-godot;
```
3. Create a **symlink** to "godot.desktop" in **"~/.local/share/applications"**.
1. Create an XML file called "x-godot.xml" in **"~/.local/share/mime/"**.
1. Edit the contents of **"x-godot.xml"**:

```xml
<?xml version="1.0" encoding="utf-8"?>
<mime-type xmlns="http://www.freedesktop.org/standards/shared-mime-info" type="application/x-godot">
  <!--Created automatically by update-mime-database. DO NOT EDIT!-->
  <comment>Godot project</comment>
  <glob pattern="*.godot"/>
</mime-type>
```
6. Open the Terminal and refresh the OS mime database: **`$ update-mime-database ~/.local/share/mime`**
1. Test it out by double clicking a "project.godot" file.
