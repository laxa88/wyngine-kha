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
	public static var DEBUG:Bool = false; // Flag true to see image/collider/quadtree boxes
	public static var DEBUG_DRAW:Bool = false; // Flag true to see image/collider/quadtree boxes

	public static var G:Wyngine; // static reference
	public static var totalMemory(get, null):Int;

	// Don't draw too many debug squares -- it'll freeze the game.
	// Keep track of draw count every render() and stop drawing if
	// it breaks a threshold.
	public static inline var DRAW_COUNT_MAX:Int = 500;
	public static var DRAW_COUNT:Int;

	public var zoom(default, null):Float;
	var thisScreen:Class<WynScreen>; // curr screen, checks against nextScreen
	var nextScreen:Class<WynScreen>; // next screen. If different from currScreen, will transition.
	var nextScreenParams:Array<Dynamic>;
	var currentScreen:WynScreen; // current game screen
	var paused:Bool = false;

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
	public function new (?startScreen:Class<WynScreen>, zoom:Float=1)
	{
		super("Wyngine");

		Wyngine.log("Wyngine new");

		// Set reference first thing first.
		G = this;

		this.zoom = zoom;

		if (startScreen == null)
			startScreen = WynScreen;

		// Switch to screen after we're done
		switchScreen(startScreen);
	}

	override public function init ()
	{
		Wyngine.log("Wyngine init");

		// By default, random numbers are seeded. Set
		// a new seed after init if necessary.
		Random.init(Std.int(Date.now().getTime()));

		// Set the starting screen sizes, which will be used when
		// screens are instanced, etc.
		windowWidth = ScreenCanvas.the.width;
		windowHeight = ScreenCanvas.the.height;
		gameWidth = Std.int(windowWidth / zoom);
		gameHeight = Std.int(windowHeight / zoom);
		buffer = Image.createRenderTarget(gameWidth, gameHeight);
		bgColor = Color.fromValue(0xff6495ed); // cornflower blue default
		cameras = [];

		// Initialise the default main camera
		cameras.push(new WynCamera(0, 0, gameWidth, gameHeight, Color.Black));

		// Initialise engine variables
		WynInput.init();
		WynTouch.init();
		WynMouse.init();
		WynAudio.init();

		// quick reference
		input = WynInput.instance;
		touch = WynTouch.instance;
		mouse = WynMouse.instance;
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

			currentScreen = cast (Type.createInstance(nextScreen, nextScreenParams));
		}

		// Get elapsed time
		_oldDt = _newDt;
		_newDt = Scheduler.time();
		dt = (_newDt - _oldDt);

		// Get FPS
		updateFps();

		// Update inputs
		input.update();
		touch.update();
		mouse.update();

		// Main game update goes here
		currentScreen.update( dt * ((paused) ? 0 : 1) );
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
			if (WynQuadTree.DEBUG)
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
	public function switchScreen (targetScreen:Class<WynScreen>, ?params:Array<Dynamic>)
	{
		// Don't immediately switch screen. Instead, flag the next screen, so
		// we can switch in the next frame. This prevents situations where a
		// new screen may immediately call switchScreen(), causing problems.

		if (params == null)
			params = [];

		nextScreen = targetScreen;
		nextScreenParams = params;
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
		if (DEBUG)
		{
			#if js
			js.Browser.console.log(str);
			#else
			trace(str);
			#end
		}
	}
}