package wyn;

import wyn.component.WynComponent;
import kha.graphics2.Graphics;

class WynObject
{
	public var x:Float = 0;
	public var y:Float = 0;
	public var angle:Float = 0; // used by sprites
	public var render:Graphics->Void;
	public var components:Array<WynComponent>;
	public var active:Bool = true; // affects alive and visible
	public var alive:Bool = true; // affects update
	public var visible:Bool = true; // affects render

	public function new ()
	{
		components = [];
	}
	
	public function update ()
	{
		if (!active)
			return;
		
		for (c in components)
			c.update();
	}

	public function destroy ()
	{
		render = null;
	}

	public function addComponent (c:WynComponent)
	{
		// Don't add duplicates, but allow multiple same-type components
		if (components.indexOf(c) == -1)
		{
			components.push(c);
			c.parent = this;
			c.init();
		}
	}

	public function removeComponent (c:WynComponent)
	{
		components.remove(c);
	}

	public function getComponent<T> (componentType:Class<T>) : T
	{
		for (c in components)
		{
			if (Std.is(c, componentType))
				return cast c;
		}

		return null;
	}

	public function getComponents<T> (componentType:Class<T>) : Array<T>
	{
		var arr:Array<T> = [];
		for (c in components)
		{
			if (Std.is(c, componentType))
				arr.push(cast c);
		}

		return arr;
	}
}