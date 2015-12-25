package wyn.manager;

import kha.input.Mouse;

class WynMouse extends WynManager
{
	public static var init:Bool = false;

	public static var x:Int = 0;
	public static var y:Int = 0;
	public static var dx:Int = 0;
	public static var dy:Int = 0;

	static var mouseDown:Map<Int, Bool>;
	static var mouseHeld:Map<Int, Bool>;
	static var mouseUp:Map<Int, Bool>;
	static var mouseCount:Int = 0;
	static var mouseJustPressed:Bool = false;

	static var startListener:Array<Int->Int->Int->Void>;
	static var endListener:Array<Int->Int->Int->Void>;
	static var moveListener:Array<Int->Int->Int->Int->Void>;

	public function new ()
	{
		super();

		Mouse.get().notify(onMouseStart, onMouseEnd, onMouseMove, onMouseWheel);

		mouseDown = new Map<Int, Bool>();
		mouseHeld = new Map<Int, Bool>();
		mouseUp = new Map<Int, Bool>();

		startListener = [];
		endListener = [];
		moveListener = [];

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

		while (startListener.length > 0)
			startListener.pop();

		while (endListener.length > 0)
			endListener.pop();

		while (moveListener.length > 0)
			moveListener.pop();
	}



	function onMouseStart (index:Int, x:Int, y:Int)
	{
		for (listener in startListener)
			listener(index, x, y);

		// trace("onMouseStart : " + index + " , " + x + " , " + y);

		mouseDown.set(index, true);
		mouseHeld.set(index, true);

		mouseCount++;

		mouseJustPressed = true;
	}

	function onMouseEnd (index:Int, x:Int, y:Int)
	{
		for (listener in endListener)
			listener(index, x, y);

		// trace("onMouseEnd : " + index + " , " + x + " , " + y);

		mouseUp.set(index, true);
		mouseHeld.remove(index);

		mouseCount--;
	}

	function onMouseMove (x:Int, y:Int, dx:Int, dy:Int)
	{
		for (listener in moveListener)
			listener(x, y, dx, dy);

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

	inline public static function isDown (index:Int=0) : Bool
	{
		return mouseDown.exists(index);
	}

	inline public static function isHeld (index:Int=0) : Bool
	{
		return mouseHeld.exists(index);
	}

	inline public static function isUp (index:Int=0) : Bool
	{
		return mouseUp.exists(index);
	}

	inline public static function isAny () : Bool
	{
		return (mouseCount > 0);
	}

	inline public static function isAnyDown () : Bool
	{
		return mouseJustPressed;
	}

	inline public static function notifyStart (func:Int->Int->Int->Void)
	{
		if (startListener.indexOf(func) == -1)
			startListener.push(func);
	}

	inline public static function notifyEnd (func:Int->Int->Int->Void)
	{
		if (endListener.indexOf(func) == -1)
			endListener.push(func);
	}

	inline public static function notifyMove (func:Int->Int->Int->Int->Void)
	{
		if (moveListener.indexOf(func) == -1)
			moveListener.push(func);
	}

	inline public static function removeStart (func:Int->Int->Int->Void)
	{
		startListener.remove(func);
	}

	inline public static function removeEnd (func:Int->Int->Int->Void)
	{
		endListener.remove(func);
	}

	inline public static function removeMove (func:Int->Int->Int->Int->Void)
	{
		moveListener.remove(func);
	}
}