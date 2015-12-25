package wyn.manager;

import kha.input.Mouse;

class WynMouse extends WynManager
{
	public static var x:Int = 0;
	public static var y:Int = 0;
	public static var dx:Int = 0;
	public static var dy:Int = 0;

	static var mouseDown:Map<Int, Bool>;
	static var mouseHeld:Map<Int, Bool>;
	static var mouseUp:Map<Int, Bool>;
	static var mouseCount:Int = 0;
	static var mouseJustPressed:Bool = false;

	public function new ()
	{
		super();

		Mouse.get().notify(onMouseStart, onMouseEnd, onMouseMove, onMouseWheel);

		mouseDown = new Map<Int, Bool>();
		mouseHeld = new Map<Int, Bool>();
		mouseUp = new Map<Int, Bool>();
	}

	override public function update ()
	{
		for (key in mouseDown.keys())
			mouseDown.remove(key);

		for (key in mouseUp.keys())
			mouseUp.remove(key);

		mouseJustPressed = false;
	}

	override public function reset ()
	{
		super.reset();

		for (key in mouseDown.keys())
			mouseDown.remove(key);

		for (key in mouseHeld.keys())
			mouseHeld.remove(key);

		for (key in mouseUp.keys())
			mouseUp.remove(key);
	}



	function onMouseStart (index:Int, x:Int, y:Int)
	{
		// trace("onMouseStart : " + index + " , " + x + " , " + y);

		mouseDown.set(index, true);
		mouseHeld.set(index, true);

		mouseCount++;

		mouseJustPressed = true;
	}

	function onMouseEnd (index:Int, x:Int, y:Int)
	{
		// trace("onMouseEnd : " + index + " , " + x + " , " + y);

		mouseUp.set(index, true);
		mouseHeld.remove(index);

		mouseCount--;
	}

	function onMouseMove (x:Int, y:Int, dx:Int, dy:Int)
	{
		// trace("onMouseMove : " + x + " , " + y + " , " + dx + " , " + dy);

		WynMouse.x = x;
		WynMouse.y = y;
		WynMouse.dx = dx;
		WynMouse.dy = dy;
	}

	function onMouseWheel (delta:Int)
	{
		// TODO
		trace("onMouseWheel : " + delta);
	}

	inline public static function isDown (index:Int=0)
	{
		mouseDown.exists(index);
	}

	inline public static function isHeld (index:Int=0)
	{
		mouseHeld.exists(index);
	}

	inline public static function isUp (index:Int=0)
	{
		mouseUp.exists(index);
	}

	inline public static function isAny (index:Int=0)
	{
		return (mouseCount > 0);
	}

	inline public static function isAnyDown (index:Int=0)
	{
		return mouseJustPressed;
	}
}