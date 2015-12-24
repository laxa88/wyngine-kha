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
			if (o.active)
				o.update();
		}
	}

	public function render (g:Graphics)
	{
		for (o in objects)
		{
			if (o.render != null && o.visible)
				o.render(g);
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