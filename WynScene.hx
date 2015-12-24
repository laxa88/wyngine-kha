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
			if (o.active && o.alive)
				o.update();
		}
	}

	public function render (g:Graphics)
	{
		for (o in objects)
		{
			for (r in o.renderers)
			{
				if (o.active && o.visible)
					r(g);
			}
		}
	}

	public function add (o:WynObject)
	{
		objects.push(o);
	}

	public function remove (o:WynObject)
	{
		objects.remove(o);
	}
}