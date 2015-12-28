package wyn;

import kha.graphics2.Graphics;

class WynScene
{
	public var objects:Array<WynObject>;

	public function new ()
	{
		objects = [];
	}
	
	public function update ()
	{
		for (o in objects)
		{
			if (o.enabled && o.active)
				o.update();
		}
	}

	public function render (g:Graphics)
	{
		for (o in objects)
		{
			for (r in o.renderers)
			{
				if (o.enabled && o.visible)
					r(g);
			}
		}
	}

	inline public function addAt (o:WynObject, index:Int)
	{
		objects.insert(index, o);
	}

	inline public function addToFront (o:WynObject, offset:Int=0)
	{
		if (offset==0)
			objects.push(o);
		else
			objects.insert(offset, o);
	}

	inline public function addToBack (o:WynObject, offset:Int=0)
	{
		if (offset==0)
			objects.unshift(o);
		else
			objects.insert(objects.length-offset, o);
	}

	inline public function remove (o:WynObject)
	{
		objects.remove(o);
	}
}