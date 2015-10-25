# Wyngine
Yet another 2D game engine for Kha.

This is intended as an experimental, learning experience for me. I'm building and adding features as I require them. The code base is influenced by HaxePunk and HaxeFlixel, because I'm still learning. Ultimately I hope it'll evolve into a usable game engine alternative for Kha.

The current philosphy I'm trying to follow for the engine is: "If it's fancy, then we probably don't need it (yet)."

The API may change drastically as I learn new techs and apply them into the overall structure of the engine. Please use at your own risk! When the engine is ready, you will see a "Getting Started" section below. If not, please be patient :)

Games made with the engine so far:
* [KhaPong](http://coinflipstudios.com/khapong) - [last working commit](https://github.com/laxa88/wyngine/commit/7cd34019ae85bb0e01accd81d680bcd5fd7d645b)
* [Khasteroids](http://coinflipstudios.com/khasteroids) - [last working commit](https://github.com/laxa88/wyngine/commit/ca7718bc0fb3797fd2c14793394d6da1673f9127)
* [KhaQuadTree](http://coinflipstudios.com/khaquadtree) - [last working commit](https://github.com/laxa88/wyngine/commit/0a576c11ad29611b7aa507452fddf5e5468e96db)

# Current Available Features

* Spritesheet Animation
* Keyboard input
* Audio
* Simple collision check
* Object Pooling
* Quad-tree collisions
* Screen states

# TODO

* Classes
  * WynBitmapText
  * WynFile

* Features
  * camera shake
  * particle and emitter
  * tiled parser
  * tile generator
  * parallax background
  * FSM
  * shaders
  * input
    * gamepad
    * touch
