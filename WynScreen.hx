package wyn;

import kha.Color;

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

		x = 0;
		y = 0;
		width = Wyngine.G.gameWidth;
		height = Wyngine.G.gameHeight;
	}

	override public function update (dt:Float)
	{
		super.update(dt);
	}

	override public function render (c:WynCamera)
	{
		super.render(c);

		// After we're done rendering this screen and all its objects,
		// try to render the camera's flash/fade stuff
		c.render();
	}

	override public function destroy ()
	{
		super.destroy();
	}

	public function onResize ()
	{
		// For you to handle whenever the screen size is changed
	}
}