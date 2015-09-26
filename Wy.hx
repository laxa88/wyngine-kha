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
	// adding objects in layers
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
	private var _layers:Map<String, Array<WyObject>>;
	private var _input:WyInput;
	private var _audio:WyAudio;
	//private var _timeSinceStart:Float; // for recording total playtime, unused
	private var _oldTime:Float;
	private var _newTime:Float;
	private var _fpsList:Array<Float> = [0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0,];
	public var _realFps:Int;
	public var _elapsed:Float;
	public var _paused:Bool;



	public function new ()
	{
		log("new");
		_layers = new Map<String, Array<WyObject>>();
		_input = new WyInput();
		_audio = new WyAudio();

		//_timeSinceStart = Scheduler.realTime();
		_newTime = Scheduler.realTime();
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

		// get fps and delta time (elapsed)
		_oldTime = _newTime;
		_newTime = Sys.getTime();
		_elapsed = _newTime - _oldTime;
		var fps:Float = 1.0 / _elapsed;
		_fpsList.unshift(fps);
		_fpsList.pop();
		var total:Float = 0;	
		for (i in 0 ... _fpsList.length)
			total += _fpsList[i];
		_realFps = Math.round(total/30.0);

		// update managers
		_input.update();

		// collide objects in each layer
		for (objects in _layers)
		{
			// Update every objects in the layer first...
			if (!_paused)
			{
				for (o in objects)
					o.update(_elapsed);
			}

			// ... Then check for collision
			// var objLen:Int = objects.length;
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

		// Draw objects
		for (objects in _layers)
		{
			for (o in objects)
				o.render(g);
		}

		g.end();

		// Draw upscaled graphics
		frame.g2.begin();
		Scaler.scale(_buffer, frame, Sys.screenRotation);
		frame.g2.end();
	}
	public function destroy ()
	{
		for (objects in _layers)
		{
			for (o in objects)
				o.destroy();
		}
		
		_buffer = null;
		_layers = null;
	}



	public function addLayer (layer:String)
	{
		if (!_layers.exists(layer))
			_layers[layer] = new Array<WyObject>();
	}
	public function add (layer:String, o:WyObject)
	{
		addLayer(layer);
		_layers[layer].push(o);
	}
	public function remove (layer:String, o:WyObject)
	{
		if (!_layers.exists(layer))
			throw "layer ["+layer+"] doesn't exist!";
		else
			_layers[layer].remove(o);
	}
	public function sortByZ(objects:Array<WyObject>)
	{
		// Use only when necessary?

		// NOTE:
		// This function doesn't care about duplicate z-indices.
		// TODO: To counter that, have a separate method
		// to sort based on y-position instead.

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