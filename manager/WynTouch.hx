package wyn.manager;

import kha.input.Surface;

class WynTouch extends WynManager
{
	public static var x:Int = 0;
	public static var y:Int = 0;
	public static var dx:Int = 0;
	public static var dy:Int = 0;

	static var touchDown:Map<Int, Bool>;
	static var touchHeld:Map<Int, Bool>;
	static var touchUp:Map<Int, Bool>;
	static var touchCount:Int = 0;
	static var touchJustPressed:Bool = false;

	static var startListener:Array<Int->Int->Int->Void>;
	static var endListener:Array<Int->Int->Int->Void>;
	static var moveListener:Array<Int->Int->Int->Void>;

	public function new ()
	{
		super();

		Surface.get().notify(onTouchStart, onTouchEnd, onTouchMove);

		touchDown = new Map<Int, Bool>();
		touchHeld = new Map<Int, Bool>();
		touchUp = new Map<Int, Bool>();

		startListener = [];
		endListener = [];
		moveListener = [];
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

		touchUp.set(index, true);
		touchHeld.remove(index);

		touchCount--;
	}

	function onTouchMove (index:Int, x:Int, y:Int)
	{
		for (listener in moveListener)
			listener(index, x, y);

		// manually get delta
		WynTouch.dx = x - WynTouch.x;
		WynTouch.dy = y - WynTouch.y;

		WynTouch.x = x;
		WynTouch.y = y;

		// trace("onTouchMove : " + index + " , " + x + " , " + y + " , " + dx + " , " + dy);
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

	inline public static function isAny (index:Int=0)
	{
		return (touchCount > 0);
	}

	inline public static function isAnyDown (index:Int=0)
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