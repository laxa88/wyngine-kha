package wyn;

import kha.math.FastVector2;
import kha.graphics2.Graphics;
import wyn.util.WynUtil;

class WynScreen
{
	// For debuggings
	public static var ID:Int = 0;
	public var isMostFront:Bool = false;
	public var id:Int;
	public var name:String = "";
	public var alive:Bool = false; // flags whether this screen can be removed from queue

	// Objects are arranged by layer, followed by array order
	var children:Array<Array<WynObject>> = [];

	// If true, will continue to update/render even if covered by other screens
	public var persistentUpdate:Bool = false;
	public var persistentRender:Bool = false;

	// for scrolling the screen.
	public var scrollX:Float = 0;
	public var scrollY:Float = 0;

	// for screen shake
	var shakeHorizontal:Bool = false;
	var shakeVertical:Bool = false;
	var intensity:Float = 0;
	var weakenRate:Float = 0;
	public var shakeX:Float = 0;
	public var shakeY:Float = 0;

	// for subscreens
	public var openCallbacks:Array<Void->Void>;
	public var closeCallbacks:Array<Void->Void>;



	public function new ()
	{
		id = ++ID;

		children = [];
		openCallbacks = [];
		closeCallbacks = [];
	}
	
	public function update ()
	{
		// Handle camera shake logic
		if (intensity > 0)
		{
			var point:FastVector2 = WynUtil.randomInCircle().mult(intensity);
			shakeX = (shakeHorizontal) ? point.x : 0;
			shakeY = (shakeVertical) ? point.y : 0;
			intensity -= Wyngine.dt * weakenRate;

			if (intensity <= 0)
			{
				shakeX = 0;
				shakeY = 0;
			}
		}

		// handle object updates
		for (layer in children)
		{
			if (layer == null)
				continue;

			for (o in layer)
			{
				if (o.enabled && o.active)
					o.update();
			}
		}
	}

	public function render (g:Graphics)
	{
		// handle object renders
		for (layer in children)
		{
			if (layer == null)
				continue;

			for (o in layer)
				tryRender(o, g);
		}
	}

	function tryRender (o:WynObject, g:Graphics)
	{
		if (o.enabled && o.visible)
		{
			for (child in o.children)
				tryRender(child, g);

			for (r in o.renderers)
				r(g);
		}
	}

	public function destroy ()
	{
		for (layer in children)
		{
			for (o in layer)
				o.destroy();
		}

		children = [];

		openCallbacks = [];
		closeCallbacks = [];
	}



	public function swapLayers (layer1:Int, layer2:Int)
	{
		// UNTESTED

		if (children[layer1] != null && 
			children[layer2] != null)
		{
			var t1 = children[layer1];
			children[layer1] = children[layer2];
			children[layer2] = t1;
		}
	}

	public function addAt (o:WynObject, layer:Int=0, index:Int)
	{
		if (children[layer] == null)
			children[layer] = [];

		o.screen = this;

		children[layer].insert(index, o);
	}

	public function addToFront (o:WynObject, layer:Int=0, offset:Int=0)
	{
		if (children[layer] == null)
			children[layer] = [];

		o.screen = this;

		if (offset==0)
			children[layer].push(o);
		else
			children[layer].insert(offset, o);
	}

	public function addToBack (o:WynObject, layer:Int=0, offset:Int=0)
	{
		if (children[layer] == null)
			children[layer] = [];

		o.screen = this;

		if (offset==0)
			children[layer].unshift(o);
		else
			children[layer].insert(children.length-offset, o);
	}

	public function remove (o:WynObject, layer:Int=0)
	{
		if (children[layer] == null)
		{
			trace("layer not found : " + layer);
			return;
		}

		// remove target child from screen
		o.screen = null;

		children[layer].remove(o);
	}



	public function open ()
	{
		// override this to init or animate the screen before it appears
		onOpen();
	}

	function onOpen ()
	{
		// override this if necessary
		alive = true;

		for (f in openCallbacks)
			f();
	}

	public function close ()
	{
		// override this to init or animate the screen
		onClose();
	}

	function onClose ()
	{
		// override this if necessary

		for (f in closeCallbacks)
			f();

		// Wyngine will check for "alive" state -- if it's dead,
		// will be removed from the queue

		alive = false;
	}



	inline public function shake (_intensity:Float=10, _weakenRate:Float=20, _shakeHorizontal:Bool=true, _shakeVertical:Bool=true)
	{
		intensity = _intensity;
		weakenRate = _weakenRate;
		shakeHorizontal = _shakeHorizontal;
		shakeVertical = _shakeVertical;
	}

	inline public function cancelEffects ()
	{
		// cancel screenshake
		shakeHorizontal = false;
		shakeVertical = false;
		intensity = 0;
		weakenRate = 0;
		shakeX = 0;
		shakeY = 0;
	}
}