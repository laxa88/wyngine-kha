package wyn;

import kha.Color;
import kha.graphics2.Graphics;

class WynScreen extends WynGroup<WynObject>
{
	/**
	 * WynScreen is like HaxeFlixel FlxState; they're fancy
	 * WynGroup that extends the most basic Wyn class.
	 */

	//public var persistentUpdate:Bool = false; // set true to update when inactive
	//public var persistentRender:Bool = true; // set true to render when inactive
	//public var bgColor:Color;



	public function new ()
	{
		super();
	}

	override public function init ()
	{
		super.init();
	}

	override public function update (dt:Float)
	{
		super.update(dt);
	}

	override public function render (g:Graphics)
	{
		super.render(g);
	}

	override public function destroy ()
	{
		super.destroy();
	}
}