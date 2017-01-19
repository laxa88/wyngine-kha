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

* [Pollen](https://wyleong.itch.io/pollen)
* [Hurdles](https://wyleong.itch.io/hurdles)
* [Adventuroads](https://wyleong.itch.io/adventuroads)
* FlappySoot (coming soon)

# Roadmap (outdated)

https://trello.com/b/LAOdvBzt/wyngine

# License

Copyright (c) 2015-2017 Leong Wai Yin, http://coinflipstudios.com/

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
