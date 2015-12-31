# Wyngine

Yet another 2D game engine for Kha.

This is intended as an experimental, learning experience for me. I'm building and adding features as I require them.

The current philosphy I'm trying to follow for the engine is: "If it's fancy, then we probably don't need it (yet)."

# Changelogs

### Wyngine 0.3 (update: 27 December 2015)

Overhauled; Wyngine is now component-based, similar to Unity. Existing classes are converted to components which can be added or removed from base WynObjects. This allows for WynObjects to be lightweight and extensible -- without any redundant inherited properties like physics, sprites or hitboxes if the gameobject doesn't require any.

### Features

* Main Objects
  * Object
  * Screen
* Components
    * Text
    * Bitmap Text
    * Button
    * Button 9-slice
    * Collider
    * Physics
    * Sprite
    * Sprite 9-slice
* Managers
  * Audio
  * Keyboard
  * Mouse
  * Touch
  * Tween

### Demos/games made with this version:

* [Pollen (v3)](http://www.funfe.com/m/play/8/Challenge-It-)

---

### Wyngine 0.2 (update: 14 December 2015)

Legacy Wyngine, based on updated version of Kha. Mostly Flixel-influenced. Code is no longer usable.

### Demos/games made with this version:

* [Pollen (v2)](http://coinflipstudios.com/pollen2)

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
* [Pollen (v1)](http://coinflipstudios.com/pollen)

---

# Roadmap

https://trello.com/b/LAOdvBzt/wyngine
