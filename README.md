# Wyngine

Yet another 2D game engine for Kha.

This is intended as an experimental, learning experience for me. I'm building and adding features as I require them.

The current philosphy I'm trying to follow for the engine is: "If it's fancy, then we probably don't need it (yet)."

Check out the [wiki](https://github.com/laxa88/wyngine/wiki) for more (outdated) info.

Wiki will be updated once Wyngine reaches v1.0.

# Changelogs

### Wyngine 0.3

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
* [Hurdles (v5)](http://coinflipstudios.com/hurdles5)

# Roadmap

https://trello.com/b/LAOdvBzt/wyngine
