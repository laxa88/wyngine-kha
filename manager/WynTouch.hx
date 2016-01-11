package wyn.manager;

import kha.input.Surface;

class WynTouch extends WynManager
{
	public static var init:Bool = false;
	public static var touches:Map<Int, TouchData>;

	static var touchDown:Map<Int, Bool>;
	static var touchHeld:Map<Int, Bool>;
	static var touchUp:Map<Int, Bool>;
	static var touchCount:Int = 0;
	static var touchJustPressed:Bool = false;

	static var startListener:Array<Int->Int->Int->Void> = [];
	static var endListener:Array<Int->Int->Int->Void> = [];
	static var moveListener:Array<Int->Int->Int->Void> = [];

	public function new ()
	{
		super();

		Surface.get().notify(onTouchStart, onTouchEnd, onTouchMove);

		touches = new Map<Int, TouchData>();

		touchDown = new Map<Int, Bool>();
		touchHeld = new Map<Int, Bool>();
		touchUp = new Map<Int, Bool>();

		startListener = [];
		endListener = [];
		moveListener = [];

		init = true;
	}

	override public function update ()
	{
		for (key in touchDown.keys())
			touchDown.remove(key);

		for (key in touchUp.keys())
			touchUp.remove(key);

		touchJustPressed = false;
	}

	override public function reset ()
	{
		super.reset();

		for (key in touches.keys())
			touches.remove(key);

		for (key in touchDown.keys())
			touchDown.remove(key);

		for (key in touchHeld.keys())
			touchHeld.remove(key);

		for (key in touchUp.keys())
			touchUp.remove(key);

		while (startListener.length > 0)
			startListener.pop();

		while (endListener.length > 0)
			endListener.pop();

		while (moveListener.length > 0)
			moveListener.pop();
	}



	function onTouchStart (index:Int, x:Int, y:Int)
	{
		for (listener in startListener)
			listener(index, x, y);

		// trace("onTouchStart : " + index + " , " + x + " , " + y);

		updateTouches(index, x, y);

		touchDown.set(index, true);
		touchHeld.set(index, true);

		touchCount++;

		touchJustPressed = true;
	}

	function onTouchEnd (index:Int, x:Int, y:Int)
	{
		for (listener in endListener)
			listener(index, x, y);

		// trace("onTouchEnd : " + index + " , " + x + " , " + y);

		touches.remove(index);

		touchUp.set(index, true);
		touchHeld.remove(index);

		touchCount--;
	}

	function onTouchMove (index:Int, x:Int, y:Int)
	{
		for (listener in moveListener)
			listener(index, x, y);

		updateTouches(index, x, y);

		// trace("onTouchMove : " + index + " , " + x + " , " + y + " , " + dx + " , " + dy);
	}

	inline function updateTouches (index:Int, x:Int, y:Int)
	{
		if (touches.exists(index))
		{
			touches[index].x = Std.int(x / Wyngine.gameScale - Wyngine.screenOffsetX);
			touches[index].y = Std.int(y / Wyngine.gameScale - Wyngine.screenOffsetY);
			touches[index].dx = Std.int((x - touches[index].x) / Wyngine.gameScale);
			touches[index].dy = Std.int((y - touches[index].y) / Wyngine.gameScale);
		}
		else
		{
			touches.set(index, {
				x : Std.int(x / Wyngine.gameScale - Wyngine.screenOffsetX),
				y : Std.int(y / Wyngine.gameScale - Wyngine.screenOffsetY),
				dx : 0,
				dy : 0
			});
		}
	}

	inline public static function isDown (index:Int=0)
	{
		return touchDown.exists(index);
	}

	inline public static function isHeld (index:Int=0)
	{
		return touchHeld.exists(index);
	}

	inline public static function isUp (index:Int=0)
	{
		return touchUp.exists(index);
	}

	inline public static function isAny ()
	{
		return (touchCount > 0);
	}

	inline public static function isAnyDown ()
	{
		return touchJustPressed;
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

	inline public static function notifyMove (func:Int->Int->Int->Void)
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

	inline public static function removeMove (func:Int->Int->Int->Void)
	{
		moveListener.remove(func);
	}
}