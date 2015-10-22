package wy;

import kha.Sys;
import kha.Game;
import kha.Color;
import kha.Image;
import kha.Scaler;
import kha.Scheduler;
import kha.Framebuffer;
import kha.ScreenRotation;
//import kha.ScreenCanvas;
//import kha.math.FastMatrix3;
import kha.math.Random;

class Wy
{
	public static var DEBUG:Bool = false;
	public static var G:Wy;

	public var _screenW:Int;
	public var _screenH:Int;
	public var _bgColor:Color;

	// Game data
	var _buffer:Image;
	var _objects:WyPool<WyObject>;

	// FPS
	var _fpsList:Array<Float> = [0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0];
	var _oldRealDt:Float;
	var _oldDt:Float;
	var _newRealDt:Float;
	var _newDt:Float;
	public var _realDt:Float;
	public var _dt:Float;
	public var _realFps:Int;

	// quattree
	var quadtree:WyQuadTree;
	var active:Bool = true;



	public function new ()
	{
		// Init variables once
		_objects = new WyPool<WyObject>();
		WyInput.init();
		WyAudio.init();
		_oldRealDt = _newRealDt = Scheduler.realTime();
		_oldDt = _newDt = Scheduler.time();

		// static reference to the engine
		G = this;
	}

	public function init (scale:Float=1.0)
	{
		// Actual canvas size is set in project.kha file.
		// The scale based on window size, to ratio

		// By default, random numbers are seeded. Set
		// a new seed after init if necessary.
		Random.init(Std.int(Date.now().getTime()));

		// this should be called between screens
		WyAudio.reset();

		//var canvasW:Float = ScreenCanvas.the.width;
		//var canvasH:Float = ScreenCanvas.the.height;
		var canvasW:Float = Game.the.width;
		var canvasH:Float = Game.the.height;
		_screenW = Std.int(canvasW / scale);
		_screenH = Std.int(canvasH / scale);
		_buffer = Image.createRenderTarget(_screenW, _screenH);
		_bgColor = Color.fromValue(0xff6495ed); // cornflower blue

		// init quadtree
		quadtree = new WyQuadTree(0, new kha.Rectangle(0, 0, _screenW, _screenH));

		log("Wyngine init : canvas[" + canvasW + "," + canvasH + "] , screen[" + _screenW + "," + _screenH + "]");
	}

	public function update ()
	{
		// This method calls every object's internal update method.
		// It does NOT process any interaction -- that is left to
		// you to code, e.g. collision via quadtrees.

		// NOTE: Kha already updates at 60fps (0.166ms elapse rate)
		// but we're getting the value here for other uses like
		// movement and animation.

		// Get elapsed time
		_oldDt = _newDt;
		_newDt = Scheduler.time();
		_dt = (_newDt - _oldDt);

		// Get FPS
		if (DEBUG)
		{
			// Only for showing fps when in debug.
			_oldRealDt = _newRealDt;
			_newRealDt = Scheduler.realTime();
			_realDt = (_newRealDt - _oldRealDt);

			_fpsList.unshift(1.0 / _realDt);
			_fpsList.pop();
			var total:Float = 0;
			for (i in 0 ... 20)
				total += _fpsList[i];
			_realFps = Math.round(total/20.0);
		}

		// update input events
		WyInput.instance.update();

		// TODO - update audio?

		// update all the game objects
		if (active)
			_objects.update(_dt);
	}

	public function render (frame:Framebuffer)
	{
		// This method only handles rendering.
		// TODO: shaders

		// Draw on the buffer
		var g = _buffer.g2;

		g.begin(true, _bgColor);
		g.color = _bgColor;
		g.fillRect(0,0,_screenW,_screenH);

		// draw quad grids before anything else
		quadtree.drawDebug(g);

		// Draw objects
		_objects.render(g);

		g.end();

		// Draw and upscale final frame
		frame.g2.begin();
		Scaler.scale(_buffer, frame, Sys.screenRotation);
		frame.g2.end();
	}



	public function add (o:WyObject)
	{
		_objects.add(o);
	}

	public function remove (o:WyObject)
	{
		_objects.remove(o);
	}

	/**
	 * TODO: follow HaxeFlixel method of checking for object1/object2 types
	 * and handling each case properly
	 *
	 * Ideally this should work like HaxeFlixel's quadtree logic.
	 * @param 	object1 	WyPool list of items
	 * @param 	object2 	WyPool list of items
	 * @param 	obj1 		callback when obj1 and obj2 collides
	 * @return 	Boolean Whether one or more overlap happened
	 */
	public function overlap (?object1:WyObject, ?object2:WyObject, ?callback:Dynamic->Dynamic->Void) : Bool
	{
		// Compare master list by default
		if (object1 == null)
			object1 = _objects;

		// Don't compare against self
		if (object2 == object1)
			object2 = null;

		// check object type
		// NOTE: for now we assume that all groups are pools.
		// in future, follow flixel format.

		quadtree.clear();
		addToQuadTree(object1);
		addToQuadTree(object2);

		// process the quadtree, magic!
		var hit:Bool = false;
		hit = quadtree.process(callback);

		// clear the quadtree and list when we're done
		// quadtree.clear();

		return hit;
	}

	function addToQuadTree (object:WyObject)
	{
		if (object == null)
			return;

		var item:WyObject;

		if (object.collisionType == WynCollisionType.GROUP)
		{
			// this is a group of objects
			var pool:WyPool<WyObject> = cast object;
			for (i in 0 ... pool.length)
			{
				item = pool._items[i];
				if (item._exists)
					quadtree.insert(item);
			}
		}
		else
		{
			// this is a single object
			if (object._exists)
				quadtree.insert(object);
		}
	}

	public function togglePause ()
	{
		active = !active;
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