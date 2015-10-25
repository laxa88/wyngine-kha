package wyn;

import kha.Sys;
import kha.Game;
import kha.Color;
import kha.Image;
import kha.Scheduler;
import kha.Framebuffer;
import kha.Scaler;
import kha.ScreenCanvas;
import kha.math.Random;

/**
 * Kha's screens are kha.Game classes.
 * To change screens, you need to do this:
 * 		Configuration.setScreen(new GameScreen());
 *
 * As a starting point for code entry, all screens
 * and subscreens will be handled via WynScreen.
 */

class Wyngine extends Game
{
	public static var DEBUG:Bool = true;
	public static var G:Wyngine; // static reference
	public var zoom(default, null):Float;
	public var startScreen:Class<WynScreen>;
	public var currentScreen:WynScreen; // current game screen
	public var windowWidth(default, null):Int; // Actual window size
	public var windowHeight(default, null):Int;
	public var gameWidth(default, null):Int; // Game's scaled resolution size
	public var gameHeight(default, null):Int;
	public var scale(default, null):Int;

	// Cameras are basically one or more image buffers
	// rendered onto the main Framebuffer.
	// TODO multiple cameras
	public var camera(default, null):Image;
	public var bgColor:Color;
	public var input:WynInput;

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

		this.startScreen = startScreen;
		this.zoom = zoom;
	}

	override public function init ()
	{
		// If startScreen is null, use default WynScreen
		if (startScreen == null)
			startScreen = WynScreen;

		// Create an instance of type startScreen, cast it as WynScreen,
		// so that we can store it into currentScreen.
		currentScreen = cast (Type.createInstance(startScreen, []));

		// Set the starting screen sizes
		windowWidth = ScreenCanvas.the.width;
		windowHeight = ScreenCanvas.the.height;
		gameWidth = Std.int(windowWidth / zoom);
		gameHeight = Std.int(windowHeight / zoom);
		camera = Image.createRenderTarget(gameWidth, gameHeight);
		bgColor = Color.fromValue(0xff6495ed); // default: cornflower blue

		// By default, random numbers are seeded. Set
		// a new seed after init if necessary.
		Random.init(Std.int(Date.now().getTime()));

		// Initialise engine variables
		WynInput.init();
		WynAudio.init();

		// quick reference
		input = WynInput.instance;

		G = this;
	}

	override public function update ()
	{
		// NOTE: Kha already updates at 60fps (0.166ms elapse rate)
		// but we're getting the value here for other uses like
		// movement and animation.

		// Get elapsed time
		_oldDt = _newDt;
		_newDt = Scheduler.time();
		dt = (_newDt - _oldDt);

		// Get FPS
		if (DEBUG)
			updateFps();

		// Update input
		input.update();

		// Main game update goes here
		currentScreen.update(dt);
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

		// Start draw on the buffer
		var g = camera.g2;
		g.begin();

		// Clear screen with bgColor
		g.color = bgColor;
		g.fillRect(0, 0, gameWidth, gameHeight);

		// Main game render goes here
		g.color = Color.White;
		currentScreen.render(g);

		g.end();

		// Draw and upscale onto final buffer
		frame.g2.begin();
		Scaler.scale(camera, frame, Sys.screenRotation);
		frame.g2.end();
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
		_quadtree = WynQuadTree.recycle(0, 0, 0, gameWidth, gameHeight);

		// Add the object or groups into two list. If o2 is null,
		// then o1 compares to itself. Otherwise, it should auto-check
		// between o1 and o2.
		_quadtree.load(o1, o2, onOverlap);

		// Process the quadtree and do call backs for each object collided.
		var hit:Bool = _quadtree.execute();

		// Destroy it after we're done.
		_quadtree.destroy();

		// Return bool whether at least ONE object overlaps in quadtree.
		return hit;
	}

	function onOverlap (o1:WynObject, o2:WynObject)
	{
		log("OVERLAP");
	}

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