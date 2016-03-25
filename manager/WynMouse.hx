package wyn.manager;

import kha.input.Mouse;

class WynMouse extends WynManager
{
	public static var init:Bool = false;

	public static var rawX:Int = 0;
	public static var rawY:Int = 0;
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

		if (Mouse.get() != null)
			Mouse.get().notify(onMouseStart, onMouseEnd, onMouseMove, onMouseWheel);

		mouseDown = new Map<Int, Bool>();
		mouseHeld = new Map<Int, Bool>();
		mouseUp = new Map<Int, Bool>();

		init = true;
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
		
		updateMouseData(x, y, 0, 0);

		mouseDown.set(index, true);
		mouseHeld.set(index, true);

		mouseCount++;

		mouseJustPressed = true;
	}

	function onMouseEnd (index:Int, x:Int, y:Int)
	{
		// trace("onMouseEnd : " + index + " , " + x + " , " + y);

		updateMouseData(x, y, 0, 0);

		mouseUp.set(index, true);
		mouseHeld.remove(index);

		mouseCount--;
	}

	function onMouseMove (x:Int, y:Int, dx:Int, dy:Int)
	{
		updateMouseData(x, y, dx, dy);
	}

	function updateMouseData (x:Int, y:Int, dx:Int, dy:Int)
	{
		// trace("updateMouseData : " + x + " , " + y + " , " + dx + " , " + dy);

		WynMouse.rawX = x;
		WynMouse.rawY = y;
		WynMouse.x = Std.int(x / Wyngine.gameScale - Wyngine.screenOffsetX);
		WynMouse.y = Std.int(y / Wyngine.gameScale - Wyngine.screenOffsetY);
		WynMouse.dx = Std.int(dx / Wyngine.gameScale);
		WynMouse.dy = Std.int(dy / Wyngine.gameScale);
	}

	function onMouseWheel (delta:Int)
	{
		// TODO
		trace("onMouseWheel : " + delta);
	}

	inline public static function isDown (index:Int=0) : Bool
	{
		return init && mouseDown.exists(index);
	}

	inline public static function isHeld (index:Int=0) : Bool
	{
		return init && mouseHeld.exists(index);
	}

	inline public static function isUp (index:Int=0) : Bool
	{
		return init && mouseUp.exists(index);
	}

	inline public static function isAny () : Bool
	{
		return init && (mouseCount > 0);
	}

	inline public static function isAnyDown () : Bool
	{
		return init && mouseJustPressed;
	}



	public static function notifyStart (func:Int->Int->Int->Void)
	{
		if (init) Mouse.get().notify(func, null, null, null);
	}

	public static function notifyEnd (func:Int->Int->Int->Void)
	{
		if (init) Mouse.get().notify(null, func, null, null);
	}

	public static function notifyMove (func:Int->Int->Int->Int->Void)
	{
		if (init) Mouse.get().notify(null, null, func, null);
	}

	public static function removeStart (func:Int->Int->Int->Void)
	{
		if (init) Mouse.get().remove(func, null, null, null);
	}

	public static function removeEnd (func:Int->Int->Int->Void)
	{
		if (init) Mouse.get().remove(null, func, null, null);
	}

	public static function removeMove (func:Int->Int->Int->Int->Void)
	{
		if (init) Mouse.get().remove(null, null, func, null);
	}
}