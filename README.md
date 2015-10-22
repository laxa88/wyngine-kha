# Wyngine
Yet another 2D game engine for Kha.

This is intended as an experimental, learning experience for me. I'm building and adding features as I require them. The code base is influenced by HaxePunk and HaxeFlixel, because I'm still learning. Ultimately I hope it'll evolve into a usable game engine alternative for Kha.

The current philosphy I'm trying to follow for the engine is: "If it's fancy, then we probably don't need it (yet)."

Games made with the engine so far:
* [KhaPong](http://coinflipstudios.com/khapong) - [last working commit](https://github.com/laxa88/wyngine/commit/7cd34019ae85bb0e01accd81d680bcd5fd7d645b)
* [Khasteroids](http://coinflipstudios.com/khasteroids) - [last working commit](https://github.com/laxa88/wyngine/commit/ca7718bc0fb3797fd2c14793394d6da1673f9127)

# Current Available Features

* Spritesheet Animation
* Keyboard input
* Audio
* Simple Rectangle Collision
* Object Pooling

# TODO

* Classes
  * WyBitmapText
  * WyFile - check if it still works

* Features
  * 9-slice
  * camera shake
  * particle and emitter
  * quad-tree collision
  * tiled parser
  * tile generator
  * parallax background
  * FSM
  * shaders
  * input
    * gamepad
    * mouse
    * touch
