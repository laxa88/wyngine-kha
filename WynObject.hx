package wyn;

import wyn.component.WynComponent;
import kha.graphics2.Graphics;

class WynObject
{
	// These are mostly for reference purposes.
	// The only thing they affect are x/y positions.
	public var parent:WynObject;
	public var children:Array<WynObject> = [];

	public var x(default, set):Float = 0;
	public var y(default, set):Float = 0;
	public var localX(default, null):Float = 0;
	public var localY(default, null):Float = 0;
	public var angle:Float = 0; // used by sprites, doesn't affect parent/children
	public var renderers:Array<Graphics->Void> = [];
	public var components:Array<WynComponent> = [];
	public var active:Bool = true; // overrides "alive" and "visible"
	public var alive:Bool = true; // affects update
	public var visible:Bool = true; // affects render

	public function new (x:Float=0, y:Float=0)
	{
		this.x = x;
		this.y = y;
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
		renderers = [];
		components = [];
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

	inline public function addRenderer (renderer:Graphics->Void)
	{
		if (renderers.indexOf(renderer) == -1)
			renderers.push(renderer);
	}

	inline public function removeRenderer (renderer:Graphics->Void)
	{
		renderers.remove(renderer);
	}

	inline public function setPosition (x:Float, y:Float)
	{
		this.x = x;
		this.y = y;
	}

	private static var delta:Float; // for reusable purposes

	private function set_x (val:Float) : Float
	{
		delta = val - x;

		for (c in children)
			c.x += delta;

		if (parent != null)
			localX = x - parent.x;
		else
			localX = x;

		return x = val;
	}

	private function set_y (val:Float) : Float
	{
		delta = val - y;

		for (c in children)
			c.y += delta;

		if (parent != null)
			localY = y - parent.y;
		else
			localY = y;

		return y = val;
	}
}