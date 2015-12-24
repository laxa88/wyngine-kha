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
	public var active:Bool = true;
	public var visible:Bool = true;

	public function new ()
	{
		components = [];
	}
	
	public function update ()
	{
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

	public function getComponent (componentType:Class<WynComponent>) : WynComponent
	{
		for (c in components)
		{
			if (Std.is(c, componentType))
				return c;
		}

		return null;
	}

	public function getComponents (componentType:Class<WynComponent>) : Array<WynComponent>
	{
		var arr:Array<WynComponent> = [];
		for (c in components)
		{
			if (Std.is(c, componentType))
				arr.push(c);
		}

		return arr;
	}
}