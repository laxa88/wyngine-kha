package wyn;

import wyn.component.WynComponent;
import kha.graphics2.Graphics;

class WynObject
{
	public var x:Int = 0;
	public var y:Int = 0;
	public var width:Int = 0;
	public var height:Int = 0;
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
}