package wyn;

import kha.math.FastVector2;
import kha.graphics2.Graphics;
import wyn.util.WynUtil;

class WynScreen
{
	// For debuggings
	public static var ID:Int = 0;
	public var id:Int;
	public var name:String = "";

	// If true, will continue to update/render even if covered by other screens
	public var alive:Bool = false;
	public var persistentUpdate:Bool = false;
	public var persistentRender:Bool = false;
	var children:Array<WynObject>;

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
		for (o in children)
		{
			if (o.enabled && o.active)
				o.update();
		}
	}

	public function render (g:Graphics)
	{
		// handle object renders
		for (o in children)
		{
			if (o.enabled && o.visible)
			{
				for (r in o.renderers)
					r(g);
			}
		}
	}

	public function destroy ()
	{
		for (o in children)
			o.destroy();

		children = null;

		openCallbacks = [];
		closeCallbacks = [];
	}



	inline public function addAt (o:WynObject, index:Int)
	{
		o.screen = this;
		children.insert(index, o);
	}

	inline public function addToFront (o:WynObject, offset:Int=0)
	{
		o.screen = this;
		if (offset==0)
			children.push(o);
		else
			children.insert(offset, o);
	}

	inline public function addToBack (o:WynObject, offset:Int=0)
	{
		o.screen = this;
		if (offset==0)
			children.unshift(o);
		else
			children.insert(children.length-offset, o);
	}

	inline public function remove (o:WynObject)
	{
		// remove target child from screen
		o.screen = null;
		children.remove(o);
	}



	public function open ()
	{
		alive = true;

		// override this to init or animate the screen before it appears
		onOpen();
	}

	function onOpen ()
	{
		// override this if necessary

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