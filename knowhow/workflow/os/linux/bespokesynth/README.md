# BespokeSynth

## Download
https://www.bespokesynth.com/
Installs using Eddy. A BespokeSynth icon is added to the OS Applications menu.


## Where to look after install?

**Q:** _Where is the executable (application/x-executable) file?_ **`BespokeSynth`**
**A:** Application path: `/usr/bin/BespokeSynth`

**Q:** **`BespokeSynth.desktop`** _Where is the .desktop file?_
**A:** File path: `/usr/share/applications/BespokeSynth.desktop`

**Q:** **`bespoke_icon.png`** _Where is the app icon?_
**A:** File path: `/usr/share/icons/hicolor/512x512/apps/bespoke_icon.png`

**Q:** _How does one override the installed **`BespokeSynth.desktop`** file?_
**A:** Make a new file with the same name at `/.local/share/applications/` + **`BespokeSynth.desktop`**




Added an icon at `/.local/share/icons/hicolor/scalable/` + **`x-bsk.svg`**

We can override the .desktop with our own.
Thumbnails `$ ~/.cache/thumbnails/` + `normal` || `large` folders.
MimeType=application/x-bespoke;application/x-bsk;

### Terminal
After editing the .desktop file: `$ update-desktop-database`
After changing a mimetype xml file: `$ update-mime-database ~/.local/share/mime/`
After adding an image to the icons folder: `update-icon-caches /home/unblinky/.local/share/icons/`

#### Trying "bespokesynth.desktop".
- Making a new desktop file: _`~/apps/bespokesynth/bespokesynth.desktop`_
- Added a symlink to the in the: _`~/.local/share/applications/`_ + **`bespokesynth.desktop`**
  - _( -> /home/unblinky/apps/bespokesynth/bespokesynth.desktop)_
- Dropped in a :  _`~/.local/share/mime/packages/`_ + **`user-extention-bks.xml`**

### Aux Folders
**`~/.local/Documents/BespokeSynth`**
**`~/.Bespoke Synth/Bespoke Synth.settings`**
**`/usr/share/BespokeSynth/resource/`** (fonts and things)
Has what in it?


```
$ dg-mime install --mode user graphml+xml-mime.xml
$ xdg-icon-resource install --context mimetypes --size 48 text-x-graphml+xml.png x-graphml+xml
$ update-mime-database ~/.local/share/mime
$ update-icon-caches ~/.local/share/icons
```
