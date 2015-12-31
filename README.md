# Wyngine

Yet another 2D game engine for Kha.

This is intended as an experimental, learning experience for me. I'm building and adding features as I require them.

The current philosphy I'm trying to follow for the engine is: "If it's fancy, then we probably don't need it (yet)."

# Getting Started

### Installation

1. [Download and install Haxe](http://haxe.org/download/)

2. [Download and setup Kha (guide)](http://htmlpreview.github.io/?https://raw.githubusercontent.com/triplefox/khaguide/master/build/book.html)

3. Download/clone Wyngine repo

4. Include Wyngine in your Kha project

5. ...?

6. Profit!

### Project Setup

Kha projects always begin from Main.hx, for example:

    package;

    import kha.Scheduler;
    import kha.System;

    class Main
    {
      public static function main ()
      {
        System.init("My Game", 800, 600, onInit);
      }

      static function onInit ()
      {
        var game = new Game();
        System.notifyOnRender(game.render);
        Scheduler.addTimeTask(game.update, 0, 1/60);
      }
    }

The Game.hx is just an arbitrary entry point. You can use any other class name, or even begin from Main.hx itself. But for readability sake, we keep them separated.

Kha is an SDL-like SDK. As such, the design of the game's flow is entirely up to you. Wyngine provides a base for the general flow of the game, but you can always choose not to use it.

An example of Game.hx can be as follows:

    package;

    import kha.System;
    import kha.Image;
    import kha.Assets;
    import kha.graphics2.Graphics;
    import kha.graphics2.ImageScaleQuality;
    import kha.Framebuffer;
    import kha.Scaler;
    import wyn.Wyngine;

    class Game
    {
      var backbuffer:Image;
      var g:Graphics;
      var init:Bool = false;
      var engine:Wyngine;

      public function new ()
      {
        Assets.loadEverything(onLoadEverything);
      }

      function onLoadEverything ()
      {
        backbuffer = Image.createRenderTarget(800, 600);
        g = backbuffer.g2;
        g.imageScaleQuality = ImageScaleQuality.High;

        Wyngine.setup(800, 600);
        Wyngine.addScreen(new GameScreen());

        init = true;
      }

      public function update ()
      {
        if (!init)
          return;

        Wyngine.update();
      }

      public function render (framebuffer:Framebuffer)
      {
        if (!init)
          return;

        g.begin(true, 0xFFc0c0c0);
        Wyngine.render(g);
        g.end();

        framebuffer.g2.begin(true, 0xFFFFFFFF);
        Scaler.scale(backbuffer, framebuffer, System.screenRotation);
        framebuffer.g2.end();
      }
    }

As shown above, we assume the first screen the game shows is GameScreen.hx:

    import kha.graphics2.Graphics;
    import wyn.Wyngine;
    import wyn.WynScreen;
    import wyn.manager.WynKeyboard;
    import wyn.manager.WynMouse;
    import wyn.manager.WynTouch;
    import wyn.manager.WynAudio;
    import wyn.manager.WynTween;

    class GameScreen extends WynScreen
    {
      public function new ()
      {
        super();

        // Add the managers we want to use in the game
        Wyngine.addManager(new WynKeyboard());
        Wyngine.addManager(new WynMouse());
        Wyngine.addManager(new WynTouch());
        Wyngine.addManager(new WynAudio());
        Wyngine.addManager(new WynTween());

        // Add event handler for HTML5 browser resize
        Wyngine.onResize = function () {};
      }

      override public function onOpen ()
      {
        super.onOpen();

        // Game setup logic goes here
      }

      override public function update ()
      {
        super.update();

        // Game update logic here
      }

      override public function render (g:Graphics)
      {
        super.render(g);

        // Game render logic here
      }
    }

If you are familiar with Unity's component-based objects, then Wyngine works similarly:

    var gameObject:WynObject;
    var sprite:WynSprite;
    var collider:WynCollider;

    override public function onOpen ()
    {
      super.onOpen();

      // Game setup logic goes here

      // Create a game object at position (100, 100)
      gameObject = new WynObject(100, 100);

      // Create any number of components for the game object

      // Create a sprite of size 64x64
      sprite = new WynSprite(64, 64);

      // Load the image into the sprite, and specify which part of the
      // spritesheet to get the image from (original image is 32x32)
      sprite.setImage(Assets.images.player_sheet, { x:0, y:0, width:32, height:32 });
      sprite.setOffset(-32, -32); // center the sprite

      // Create a collider for the sprite for collision checks
      collider = new WynCollider(48, 48);
      collider.setOffset(-32, -32); // center the collider

      // Add component to game object
      gameObject.addComponent(sprite);
      gameObject.addComponent(collider);

      addToFront(gameObject);
    }

All game objects added to the screen will be automatically updated in the `update()` method. 

If the game object has an image (sprite, button, bitmaptext), it will also be rendered in the `render()` method.

Objects are updated and rendered in the order they were added to the screen (via `addToFront()` and `addToBack()`), but if you would like to update/render them in a custom order, you can just skip using the `addToFront()` and `addToBack()` methods completely - and just call the object's `update()` and component's `render()` methods directly. This is more tedious but it's also the most flexible, as you get to decide how and when each object/component is updated and rendered. Here is an example:

    override public function onOpen ()
    {
      super.onOpen();

      // Game setup logic goes here

      // Omitted from code above...

      // You can choose not to add the gameObject to
      // the screen directly.
      // addToFront(gameObject);
    }

    override public function update ()
    {
      super.update();

      // You can manually update your game objects
      // whether they were added to the screen or not.
      gameObject.update();
    }

    override public function render (g:Graphics)
    {
      // Just like update(), you can manually render
      // components in two ways:

      // render everything hooked to the gameObject...
      for (render in gameObject.renderers)
        render(g);

      // ... or render it directly
      sprite.render(g);
    }

### Examples

Coming soon...?

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

### Wyngine 0.2 (update: 14 December 2015)

Legacy Wyngine, based on updated version of Kha. Mostly Flixel-influenced. Code is no longer usable.

### Demos/games made with this version:

* [Pollen (v2)](http://coinflipstudios.com/pollen2)

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

# Roadmap

https://trello.com/b/LAOdvBzt/wyngine
