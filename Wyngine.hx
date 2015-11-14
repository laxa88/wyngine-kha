package wyn;

import kha.Sys;
import kha.Game;
import kha.Color;
import kha.Image;
import kha.Loader;
import kha.Scheduler;
import kha.Framebuffer;
import kha.Scaler;
import kha.ScreenCanvas;
import kha.math.Random;
import kha.graphics2.Graphics;

/**
 * Kha's screens are kha.Game classes.
 * Wyngine abstracts everything away, now handling all the
 * core update/render logic. It's now very much like
 * HaxeFlixel -- create a new WynScreen and start writing
 * your game in it.
 */

class Wyngine extends Game
{
	public static inline var FIT_NONE:Int = 0;
	public static inline var FIT_WIDTH:Int = 1;
	public static inline var FIT_HEIGHT:Int = 2;

	public static var DEBUG_LOG:Bool = false; // Flag true to see image/collider/quadtree boxes
	public static var DEBUG_DRAW:Bool = false; // Flag true to see image/collider/quadtree boxes
	public static var DEBUG_QUAD:Bool = false; // Flag true to see image/collider/quadtree boxes

	public static var G:Wyngine; // static reference
	public static var totalMemory(get, null):Int;

	// Don't draw too many debug squares -- it'll freeze the game.
	// Keep track of draw count every render() and stop drawing if
	// it breaks a threshold.
	public static inline var DRAW_COUNT_MAX:Int = 500;
	public static var DRAW_COUNT:Int;

	public var zoom(default, null):Float = 1;
	var thisScreen:Class<WynScreen>; // curr screen, checks against nextScreen
	var nextScreen:Class<WynScreen>; // next screen. If different from currScreen, will transition.
	var currentScreen:WynScreen; // current game screen
	var paused:Bool = false;

	public var oriWidth(default, null):Int;
	public var oriHeight(default, null):Int;

	public var windowWidth(default, null):Int; // Actual window size
	public var windowHeight(default, null):Int;
	public var gameWidth(default, null):Int; // Game's scaled resolution size
	public var gameHeight(default, null):Int;
	public var loadPercentage(get, null):Float;

	// Cameras are basically one or more image buffers
	// rendered onto the main Framebuffer.
	// TODO multiple cameras
	public var buffer(default, null):Image;
	public var bgColor(default, set):Color;
	public var cameras(default, null):Array<WynCamera>;
	var input:WynInput;
	var touch:WynTouch;
	var mouse:WynMouse;
	var tween:WynTween;

	// Have one reusable quadtree container so we don't
	// end up creating new variable every update.
	var _quadtree:WynQuadTree;

	// Debug - fps
	var _oldRealDt:Float;
	var _newRealDt:Float;
	var _oldDt:Float;
	var _newDt:Float;
	var _fpsList:Array<Float> = [0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0];
	public var realDt:Float; // actual delta time between each update
	public var dt:Float; // constant 1/60fps delta time
	public var fps:Int; // fps for debug purposes



	/**
	 * Entry point for Wyngine.
	 * Note: Window width/height is based on project.kha config.
	 * @param 	zoom 	If window = 640x480, then if zoom=2,
	 * 					then output resolution is 320x240.
	 */
	public function new (startScreen:Class<WynScreen>, zoom:Float)
	{
		super("Wyngine");

		Wyngine.log("Wyngine new");

		// Set reference first thing first.
		G = this;

		this.zoom = zoom;

		// Switch to screen after we're done
		switchScreen(startScreen);
	}

	override public function init ()
	{
		Wyngine.log("Wyngine init");

		// Save original size first, so that we can rescale the
		// screen for HTML5 pages
		oriWidth = ScreenCanvas.the.width;
		oriHeight = ScreenCanvas.the.height;

		// By default, random numbers are seeded. Set
		// a new seed after init if necessary.
		Random.init(Std.int(Date.now().getTime()));

		// Set the starting screen sizes, which will be used when
		// screens are instanced, etc.
		bgColor = Color.fromValue(0xff6495ed); // cornflower blue default

		// Update the game size variables according to the
		// window (or HTML5 canvas) size, and update the buffer too.
		windowWidth = ScreenCanvas.the.width;
		windowHeight = ScreenCanvas.the.height;
		gameWidth = Std.int(windowWidth / zoom);
		gameHeight = Std.int(windowHeight / zoom);
		buffer = Image.createRenderTarget(gameWidth, gameHeight);

		// Initialise the default main camera
		resetCameras();

		// Initialise engine variables
		WynInput.init();
		WynTouch.init();
		WynMouse.init();
		WynAudio.init();
		WynTween.init();

		// quick reference
		input = WynInput.instance;
		touch = WynTouch.instance;
		mouse = WynMouse.instance;
		tween = WynTween.instance;

		// Start with the originally specified zoom
		setGameZoom(zoom);
	}

	public function initMobileMode ()
	{
		#if js

		// Prevents mobile touches from scrolling the screen.
		kha.Sys.khanvas.addEventListener("touchstart", function (e:js.html.Event) {
			e.preventDefault();
		});

		// Makes sure that any further resize will trigger this
		js.Browser.window.addEventListener("resize", resizeBrowserGameScreen);

		// Call resize once
		resizeBrowserGameScreen();

		// resets to one full-screen camera
		resetCameras();

		#end
	}

	function resizeBrowserGameScreen ()
	{
		#if js

		// Resize to fit full screen of the browser page.
		// NOTE: if there's unnecessary padding, make sure
		// to modify the index.html so that the <html>, <body>
		// and <p> have zero margin and zero padding.
		kha.Sys.khanvas.width = js.Browser.window.innerWidth;
		kha.Sys.khanvas.height = js.Browser.window.innerHeight;

		// We don't know if the new screen size will be proportionate,
		// so it's not a good idea to update each camera's sizes.
		// for (cam in cameras)
		// {
		// 	cam.width = gameWidth;
		// 	cam.height = gameHeight;
		// }

		// Instead of resizing the camera, just do a callback
		// to current screen so the user can handle it manually.
		if (currentScreen != null)
			currentScreen.onResize();

		#end
	}

	public function resetCameras ()
	{
		cameras = [];
		cameras.push(new WynCamera(0, 0, gameWidth, gameHeight, Color.Black));
	}

	override public function update ()
	{
		// NOTE: Kha already updates at 60fps (0.166ms elapse rate)
		// but we're getting the value here for other uses like
		// movement and animation.

		// Switch to the new screen in this cycle
		if (thisScreen != nextScreen)
		{
			thisScreen = nextScreen;

			if (currentScreen != null)
				currentScreen.destroy();

			// Initialise some stuff that shouldn't carry over between screens
			WynAudio.reset();

			currentScreen = cast (Type.createInstance(nextScreen, []));
		}

		// Get elapsed time
		_oldDt = _newDt;
		_newDt = Scheduler.time();
		dt = (_newDt - _oldDt);

		// Get FPS
		updateFps();

		// Get dt based on whether it's paused or not
		var _dt = dt * ((paused) ? 0 : 1);

		// Update inputs
		input.update();
		touch.update();
		mouse.update();
		//audio.update(); // no need for this yet
		tween.update(_dt);

		// Update each camera if they have effects, such as
		// shake, flash, fade...
		var cam:WynCamera;
		for (i in 0 ... cameras.length)
		{
			cam = cameras[i];
			cam.update(_dt);
		}

		// Main game update goes here
		currentScreen.update(_dt);
	}

	function updateFps ()
	{
		// Only for showing fps when in debug.
		_oldRealDt = _newRealDt;
		_newRealDt = Scheduler.realTime();
		realDt = (_newRealDt - _oldRealDt);

		_fpsList.unshift(1.0 / realDt);
		_fpsList.pop();
		var total:Float = 0;
		for (i in 0 ... 20)
			total += _fpsList[i];
		fps = Math.round(total/20.0);
	}

	override public function render (frame:Framebuffer)
	{
		// TODO: shaders

		var g:Graphics;
		var cam:WynCamera;

		for (i in 0 ... cameras.length)
		{
			cam = cameras[i];

			// For every camera, render the current screen onto their buffers.
			g = cam.buffer.g2;

			// Clear screen with bgColor
			g.begin(true, cam.bgColor);

			// Draw quadtree if you want
			if (DEBUG_QUAD)
			{
				if (_quadtree != null)
					_quadtree.drawTrees(cam);
			}

			// Draw each object onto current camera
			g.color = Color.White;
			currentScreen.render(cam);

			g.end();
		}

		// Draw the cameras onto the buffer
		g = buffer.g2;

		// Clear main screen before drawing cameras in
		g.begin(true, bgColor);

		// Reset to white when rendering camera, otherwise
		// we end up tinting color to all the cameras
		g.color = Color.White;

		for (i in 0 ... cameras.length)
		{
			cam = cameras[i];
			g.drawScaledSubImage(cam.buffer,
				0, // frame origin (like WynSprite)
				0,
				cam.width / cam.zoom, // frame size (like WynSprite.)
				cam.height / cam.zoom,
				cam.x,
				cam.y,
				cam.width, // the actual camera size on screen
				cam.height);
		}
		g.end();

		// Once we're done, draw and upscale the buffer onto screen
		frame.g2.begin();
		Scaler.scale(buffer, frame, Sys.screenRotation);
		frame.g2.end();

		// Reset at end of every cycle
		DRAW_COUNT = 0;
	}

	override public function onForeground():Void
	{
		// TODO
		log("onForeground");
	}
	override public function onResume():Void
	{
		// TODO
		log("onResume");
	}
	override public function onPause():Void
	{
		// TODO
		log("onPause");
	}
	override public function onBackground():Void
	{
		// TODO
		log("onBackground");
	}
	override public function onShutdown():Void
	{
		// TODO
		log("onShutdown");
	}

	/**
	 * Wyngine methods go here
	 */

	/**
	 * This is an engine-level method that lets you check any WynObject
	 * against another WynObject. It can be either be:
	 * 		single (WynSprite)
	 *  	group (WynGroup) 
	 * 		tile (TODO)
	 * In short, it should be as convenient as HaxeFlixel's overlap().
	 */
	public function overlap (?o1:WynObject, ?o2:WynObject, ?callback:Dynamic->Dynamic->Void) : Bool
	{
		// If no parameter specified, compare all objects in current screen.
		if (o1 == null)
			o1 = currentScreen;

		// Don't compare against self
		if (o2 == o1)
			o2 = null;

		// Note: For now, getting a new quad tree will reset its
		// bounds to the current screen size. Haxeflixel actually
		// allows you to set manual bounds here instead... TODO?
		if (_quadtree != null)
			_quadtree.destroy();

		_quadtree = WynQuadTree.recycle(0, 0, 0, gameWidth, gameHeight);

		// Add the object or groups into two list. If o2 is null,
		// then o1 compares to itself. Otherwise, it should auto-check
		// between o1 and o2.
		_quadtree.load(o1, o2, callback);

		// Process the quadtree and do call backs for each object collided.
		var hit:Bool = _quadtree.execute();

		// Destroy it after we're done.
		// _quadtree.destroy();

		// Return bool whether at least ONE object overlaps in quadtree.
		return hit;
	}

	/**
	 * Change screens. There's no fade logic -- Do it inside the
	 * screen manually before calling this method. NOTE:
	 * Switching a screen will destroy the previous screen.
	 */
	public function switchScreen (targetScreen:Class<WynScreen>)
	{
		// Don't immediately switch screen. Instead, flag the next screen, so
		// we can switch in the next frame. This prevents situations where a
		// new screen may immediately call switchScreen(), causing problems.
		nextScreen = targetScreen;
	}

	/**
	 * This is just a method that abstracts away kha's method,
	 * for convenience sake.
	 */
	public function loadAssets (name:String, callback:Void->Void)
	{
		Loader.the.loadRoom(name, callback);
	}

	public function togglePause ()
	{
		paused = !paused;
	}



	/**
	 * Instead of setting camera zoom, you can set the screen's zoom,
	 * to create true pixel resolution screens. This also updates all
	 * cameras to match the new game's zoom.
	 */
	public function setGameZoom (zoom:Float, affectCameras:Bool=true)
	{
		var oldZoom = this.zoom; // e.g. 2
		this.zoom = zoom; // e.g. 1

		// e.g. 2 / 1 = 2
		// This means all existing cameras need to be upscaled x2.
		var ratio = zoom / oldZoom;

		// update game resolution
		gameWidth = Std.int(windowWidth / zoom);
		gameHeight = Std.int(windowHeight / zoom);

		// Update buffer size
		buffer = Image.createRenderTarget(gameWidth, gameHeight);

		// By default, camera sizes are resized according to resolution.
		if (affectCameras)
		{
			// Update all existing cameras. This should intelligently
			// scale the camera's x/y/width/height/scrollX/scrollY.
			for (cam in cameras)
			{
				// NOTE:
				// zoom is not updated, because... not sure if it's necessary.
				cam.x /= ratio;
				cam.y /= ratio;
				cam.width /= ratio;
				cam.height /= ratio;

				// Update the camera buffer size
				cam.buffer = Image.createRenderTarget(cast cam.width, cast cam.height);
			}
		}
	}

	/**
	 * Replaces all the current cameras with this new list of cameras
	 */
	public function initCameras (newCameras:Array<WynCamera>)
	{
		cameras = [];
		for (cam in newCameras)
		{
			// Just double-check and don't insert duplicate cams
			if (cameras.indexOf(cam) == -1)
				cameras.push(cam);
		}
	}

	/**
	 * Sets a new camera to the index. Returns true if success.
	 */
	public function setCamera (index:Int, camera:WynCamera) : Bool
	{
		if (index < 0 || index >= cameras.length)
			return false;
		
		cameras[index] = camera;
		return true;
	}

	/**
	 * Adds a new camera to the camera list.
	 */
	public function addCamera (camera:WynCamera)
	{
		// Don't add duplicates
		if (cameras.indexOf(camera) != -1)
			return;

		cameras.push(camera);
	}



	private function get_loadPercentage () : Float
	{
		return Loader.the.getLoadPercentage();
	}

	private function set_bgColor (val:Color) : Color
	{
		// NOTE:
		// Works on dynamic platforms, but not static platforms.
		// http://haxe.org/manual/types-nullability.html
		// if (val == null)
		// 	val = Color.fromValue(0xff6495ed);

		return (bgColor = val);
	}

	/**
	 * Refer to:
	 * https://github.com/openfl/openfl/blob/master/openfl/system/System.hx
	 * https://developer.mozilla.org/en-US/docs/Web/API/Window/performance
	 */
	@:noCompletion private static function get_totalMemory () : Int
	{
		// NOTE:
		// For now, HTML5 doesn't give the value we want.
		// I don't know how to get memory for other platforms.

		#if flash
		return flash.system.System.totalMemory;
		#else
		return -1;
		#end
	}

	/**
	 * Wyngine-level debug method. Right now it's tested only
	 * on HTML5, but if there's a need for special logs in other
	 * platforms, I'll add them here.
	 */
	public static function log (str:String)
	{
		if (DEBUG_LOG)
		{
			#if js
			js.Browser.console.log(str);
			#else
			trace(str);
			#end
		}
	}
}