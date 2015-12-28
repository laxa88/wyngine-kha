# Wyngine

Yet another 2D game engine for Kha.

This is intended as an experimental, learning experience for me. I'm building and adding features as I require them.

The current philosphy I'm trying to follow for the engine is: "If it's fancy, then we probably don't need it (yet)."

The API may change drastically as I learn new techs and apply them into the overall structure of the engine. Please use at your own risk! When the engine is ready, you will see a "Getting Started" section below. If not, please be patient :)

# Changelogs

### Wyngine 0.3 (update: 27 December 2015)

Overhauled; Wyngine is now component-based, similar to Unity. Existing classes are converted to components which can be added or removed from base WynObjects. This allows for WynObjects to be lightweight and extensible -- without any redundant inherited properties like physics, sprites or hitboxes if the gameobject doesn't require any.

### Features

* Input
  * Keyboard
  * Mouse
  * Touch (untested)
* Audio
  * Play BGM
  * Play sound
* Text
  * Default Kha text
  * Bitmap text
* Images, 9-slice images
* Buttons, 9-slice buttons
* Simple physics (velocity, accel, decel)
* Simple colliders (rect, circle)
* Helper classes (Util, Math)

### Demos/games made with this version:

* None

---

### Wyngine 0.2 (update: 14 December 2015)

Legacy Wyngine, based on updated version of Kha. Mostly Flixel-influenced. Code is no longer usable.

### Demos/games made with this version:

* [Pollen (game)](http://coinflipstudios.com/pollen2)

---

### Wyngine 0.1

Legacy Wyngine, based on previous version of Kha. Modelled after Flixel/HaxePunk. Code is no longer usable.

### Demos/games made with this version:

* [KhaPong](http://coinflipstudios.com/khapong)
* [Khasteroids](http://coinflipstudios.com/khasteroids)
* [KhaQuadTree](http://coinflipstudios.com/khaquadtree)
* [KhaMenu](http://coinflipstudios.com/khamenu)
* [KhaCamera (multiple cameras, scroll)](http://coinflipstudios.com/khacamera)
* [KhaCamera (flash, fill, fadeIn, fadeOut)](http://coinflipstudios.com/khacamera2)
* [KhaButton (image, 9-slice image, button, 9-slice button)](http://coinflipstudios.com/khabutton)
* [Pollen (game)](http://coinflipstudios.com/pollen)

---

# Roadmap

https://trello.com/b/LAOdvBzt/wyngine
