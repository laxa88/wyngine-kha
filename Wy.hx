package wy;

import haxe.ds.ArraySort;
import kha.Sys;
import kha.Game;
import kha.Color;
import kha.Image;
import kha.Loader;
import kha.Scaler;
import kha.Key;
import kha.Scheduler;
import kha.Framebuffer;
import kha.ScreenRotation;
import kha.ScreenCanvas;
import kha.audio1.Audio;
import kha.input.Keyboard;
import kha.math.FastMatrix3;
import kha.math.Random;
import kha.StorageFile;

class Wy
{
	/**
		Wyngine's focus on simplicity and barebones. If it's fancy,
		then we probably don't need it.

		NOTES:
		* none

		TODO
			WyBitmapText
			WyFile - check if it still works
			WySprite - remove?

			9-slice
			object pool
			camera shake
			particle and emitter
			quad-tree collision
			tiled parser
			tile generator
			parallax background
			fsm

			input
				gamepad
				mouse
				touch
	*/

	public static var DEBUG:Bool = false;
	public static var G:Wy;

	public var _screenW:Int;
	public var _screenH:Int;
	public var _bgColor:Color;

	// Game data
	var _buffer:Image;
	var _objects:Array<WyObject>;

	// FPS
	var _fpsList:Array<Float> = [0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0];
	var _oldRealDt:Float;
	var _oldDt:Float;
	var _newRealDt:Float;
	var _newDt:Float;
	public var _realDt:Float;
	public var _dt:Float;
	public var _realFps:Int;



	public function new ()
	{
		// Init variables once
		_objects = new Array<WyObject>();
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
		for (o in _objects)
		{
			if (o._active)
				o.update(_dt);
		}

		// NOTE:
		// for now, just do basic rect collision checks.
		// in the future, use quad trees.
		// var objLen:Int = _objects.length;
		// for (j in 0 ... objLen)
		// {
		// 	// TODO: this logic is not optimised!
		// 	for (k in 0 ... objLen)
		// 	{
		// 		if (j != k)
		// 			objects[j].collide(objects[k]);
		// 	}
		// }
	}

	public function render (frame:Framebuffer)
	{
		// This method only handles rendering.
		// TODO: shaders

		// Draw on the buffer
		var g = _buffer.g2;

		g.begin();
		//g.color = Color.White;
		g.color = _bgColor;
		g.transformation = FastMatrix3.identity();
		g.fillRect(0,0,_screenW,_screenH);

		// Draw objects
		for (o in _objects)
		{
			if (o._visible)
				o.render(g);
		}

		g.end();

		// Draw and upscale final frame
		frame.g2.begin();
		Scaler.scale(_buffer, frame, Sys.screenRotation);
		frame.g2.end();
	}



	public function add (o:WyObject)
	{
		_objects.push(o);
	}

	public function remove (o:WyObject)
	{
		_objects.remove(o);
	}

	public function overlap (obj1:WyObject, obj2:WyObject, cb:WyObject->WyObject->Void) : Bool
	{
		if (obj1.collide(obj2))
		{
			cb(obj1, obj2);
			return true;
		}

		return false;
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