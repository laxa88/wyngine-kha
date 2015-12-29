package wyn;

import kha.math.FastVector2;
import kha.graphics2.Graphics;
import wyn.util.WynUtil;

class WynScreen
{
	// If true, will continue to update/render even if covered by other screens
	public var persistentUpdate:Bool = false;
	public var persistentRender:Bool = false;
	public var objects:Array<WynObject>;

	// for scrolling the screen.
	public var scrollX:Float = 0;
	public var scrollY:Float = 0;

	// for screen shake
	public var shakeHorizontal:Bool = false;
	public var shakeVertical:Bool = false;
	public var intensity:Float = 0;
	public var weakenRate:Float = 0;
	public var shakeX:Float = 0;
	public var shakeY:Float = 0;



	public function new ()
	{
		objects = [];
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
		for (o in objects)
		{
			if (o.enabled && o.active)
				o.update();
		}
	}

	public function render (g:Graphics)
	{
		// handle object renders
		for (o in objects)
		{
			for (r in o.renderers)
			{
				if (o.enabled && o.visible)
					r(g);
			}
		}
	}

	public function destroy ()
	{
		for (o in objects)
			o.destroy();

		objects = null;
	}



	inline public function addAt (o:WynObject, index:Int)
	{
		o.screen = this;
		objects.insert(index, o);
	}

	inline public function addToFront (o:WynObject, offset:Int=0)
	{
		o.screen = this;
		if (offset==0)
			objects.push(o);
		else
			objects.insert(offset, o);
	}

	inline public function addToBack (o:WynObject, offset:Int=0)
	{
		o.screen = this;
		if (offset==0)
			objects.unshift(o);
		else
			objects.insert(objects.length-offset, o);
	}

	inline public function remove (o:WynObject)
	{
		o.screen = null;
		objects.remove(o);
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