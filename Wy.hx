package wy;

import haxe.ds.ArraySort;
import kha.Color;
import kha.Image;
import kha.Loader;
import kha.Scaler;
import kha.Sys;
import kha.Key;
import kha.Scheduler;
import kha.Framebuffer;
import kha.audio1.Audio;
import kha.input.Keyboard;
import kha.math.FastMatrix3;
import kha.StorageFile;

class Wy
{
	// TODO
	// framerate
	// debugger
	// game states
	// input pooling
	// camera list
	// screen scale / modes
	// collide / overlap / quadtrees
	// openURL

	private var _canvasW:Int;
	private var _canvasH:Int;
	private var _screenW:Int;
	private var _screenH:Int;
	private var _screenScale:Float;
	private var _buffer:Image;
	private var _objects:Array<WyObject>;
	private var _input:WyInput;
	private var _audio:WyAudio;
	//private var _timeSinceStart:Float; // for recording total playtime, unused
	private var _timeSinceLastFrame:Float;



	public function new ()
	{
		log("new");
		_objects = new Array<WyObject>();
		_input = new WyInput();
		_audio = new WyAudio();

		//_timeSinceStart = Scheduler.realTime();
		_timeSinceLastFrame = Scheduler.realTime();
	}
	public function setScreenBySize (width:Int, height:Int)
	{
		// Actual canvas size is set in project.kha file.
		// The w and h here is the resolution of the canvas.
		_buffer = Image.createRenderTarget(width, height);
	}
	public function setScreenByScale (scale:Float)
	{
		// Actual canvas size is set in project.kha file.
		// The scale based on window size, to ratio
		_screenScale = scale;
		_canvasW = kha.ScreenCanvas.the.width;
		_canvasH = kha.ScreenCanvas.the.height;
		_screenW = Std.int(_canvasW / _screenScale);
		_screenH = Std.int(_canvasH / _screenScale);
		log(_canvasW + " , " + _canvasH + " / " + _screenW + " , " + _screenH);
		_buffer = Image.createRenderTarget(_screenW, _screenH);
	}
	public function update ()
	{
		// NOTE: Kha already updates at 60fps (0.166ms elapse rate)
		// but we're getting the value here for other uses like
		// movement and animation.

		// get delta time (elapsed)
		var now:Float = Scheduler.realTime();
		var elapsed:Float = now - _timeSinceLastFrame;
		_timeSinceLastFrame = now;

		// update managers
		_input.update();

		// collide objects
		// for (i in 0 ... _objects.length-1)
		// 	_objects[i].collide(_objects[i+1]);

		// sort sprites
		sort(_objects);

		// update position and other logic
		for (o in _objects)
			o.update(elapsed);
	}
	public function render (frame:Framebuffer)
	{
		var g = _buffer.g2;
		g.begin();

		// Clear screen
		g.color = Color.White;
		g.transformation = FastMatrix3.identity();

		// Draw debug line for halfscreen
		g.color = Color.fromBytes(0, 255, 0);
		g.drawRect(0, 0, _screenW/2, _screenH/2);
		g.drawRect(_screenW/2, _screenH/2, _screenW/2, _screenH/2);

		// Draw sprites
		for (o in _objects)
			o.render(g);

		g.end();

		// Draw upscaled graphics
		frame.g2.begin();
		Scaler.scale(_buffer, frame, Sys.screenRotation);
		frame.g2.end();
	}
	public function destroy ()
	{
		for (item in _objects)
			item.destroy();
		
		_buffer = null;
		_objects = null;
	}



	public function add (o:WyObject)
	{
		_objects.push(o);
	}
	function sort(objects:Array<WyObject>)
	{
		// TODO
		// don't allow duplicate z-index

		// Sorts sprites by z-index
		if (objects.length == 0) return;
		ArraySort.sort(objects, function(arg0: WyObject, arg1: WyObject)
		{
			if (arg0._z < arg1._z) return -1;
			else if (arg0._z == arg1._z) return 0;
			else return 1;
		});
	}



	public static function log (str:String)
	{
		js.Browser.console.log(str);
	}
}