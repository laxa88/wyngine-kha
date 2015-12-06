# Wyngine
Yet another 2D game engine for Kha.

This is intended as an experimental, learning experience for me. I'm building and adding features as I require them. The code base is influenced by HaxePunk and HaxeFlixel, because I'm still learning. Ultimately I hope it'll evolve into a usable game engine alternative for Kha.

The current philosphy I'm trying to follow for the engine is: "If it's fancy, then we probably don't need it (yet)."

The API may change drastically as I learn new techs and apply them into the overall structure of the engine. Please use at your own risk! When the engine is ready, you will see a "Getting Started" section below. If not, please be patient :)

Demos made with the engine so far:
* [KhaPong](http://coinflipstudios.com/khapong) - [last working commit](https://github.com/laxa88/wyngine/commit/7cd34019ae85bb0e01accd81d680bcd5fd7d645b)
* [Khasteroids](http://coinflipstudios.com/khasteroids) - [last working commit](https://github.com/laxa88/wyngine/commit/ca7718bc0fb3797fd2c14793394d6da1673f9127)
* [KhaQuadTree](http://coinflipstudios.com/khaquadtree) - [last working commit](https://github.com/laxa88/wyngine/commit/0a576c11ad29611b7aa507452fddf5e5468e96db)
* [KhaMenu](http://coinflipstudios.com/khamenu) - [last working commit](https://github.com/laxa88/wyngine/commit/eff998996195f419a062e26055c9885cc840e5b2)
* [KhaCamera (multiple cameras, scroll)](http://coinflipstudios.com/khacamera) - [last working commit](https://github.com/laxa88/wyngine/commit/e533d9fbaf09d868666d32b306956872c44775fa)
* [KhaCamera (flash, fill, fadeIn, fadeOut)](http://coinflipstudios.com/khacamera2) - [last working commit](https://github.com/laxa88/wyngine/commit/c4efb971e1901af2ab98d077cfa4d8348340ee6f)
* [KhaButton (image, 9-slice image, button, 9-slice button)](http://coinflipstudios.com/khabutton) - [last working commit](https://github.com/laxa88/wyngine/commit/a393e6f0f48227323a25f2a7a45634ff722592ac)
* [Pollen (game)](http://coinflipstudios.com/pollen) - [last working commit](https://github.com/laxa88/wyngine/commit/49afbcf2f11f1006dbf421894ee57b2116a6c0a0)

# Current Available Features

* Sprite animation
* Input
	* Keyboard
	* Mouse
	* Touch (untested)
* Audio
	* Play BGM
	* Play sound
* Simple collision check
* Object Pooling
* Quad-tree collisions
* Screen states
* Text
	* Default Kha text
	* Bitmap text
* Camera system (multiple cameras, scrolling, zooming, shake, flash, fade, fill)
* 9-slice image
* Buttons, 9-slice buttons
* Tweening (with [David King's refactored code](https://github.com/oodavid/timestep/blob/master/src/animate/transitions.js) based on [Andrey Sitnik's easings.net](http://easings.net/))
* Particle system (for explosions & smoke effects)
* Subscreens (similar to Flixel's SubStates)

# TODO

https://trello.com/b/LAOdvBzt/wyngine

# NOTES

Wyngine is currently based on legacy Kha code. The most recent (as of December 5 2015) is still unstable and mostly broken, so I have not updated Wyngine to to sync with them yet.
