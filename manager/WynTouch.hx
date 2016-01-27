package wyn.manager;

import kha.input.Surface;

class WynTouch extends WynManager
{
	public static var init:Bool = false;
	public static var touches:Map<Int, TouchData>;

	static var touchCount:Int = 0;
	static var touchJustPressed:Bool = false;

	public function new ()
	{
		super();

		Surface.get().notify(onTouchStart, onTouchEnd, onTouchMove);

		touches = new Map<Int, TouchData>();

		init = true;
	}

	override public function update ()
	{
		for (key in touches.keys())
		{
			var touch = touches[key];

			// bugfix for safari, otherwise will break everything
			if (touch == null)
				continue;

			if (touch.state == InputState.DOWN)
			{
				touch.state = InputState.HELD;
			}
			else if (touch.state == InputState.UP)
			{
				touch.state = InputState.NONE;
			}
		}

		touchJustPressed = false;
	}

	override public function reset ()
	{
		super.reset();

		for (key in touches.keys())
			touches.remove(key);
	}



	function onTouchStart (index:Int, x:Int, y:Int)
	{
		// Every time a touch is detected, we assume the player is on
		// mobile, so disable the mouse manager immediately.
		WynMouse.init = false;

		trace("onTouchStart : " + index + " , " + x + " , " + y);

		updateTouch(index, x, y);
		touches[index].state = InputState.DOWN;

		touchCount++;

		touchJustPressed = true;
	}

	function onTouchEnd (index:Int, x:Int, y:Int)
	{
		trace("onTouchEnd : " + index + " , " + x + " , " + y);

		updateTouch(index, x, y);
		touches[index].state = InputState.UP;

		touchCount--;
	}

	function onTouchMove (index:Int, x:Int, y:Int)
	{
		updateTouch(index, x, y);

		// trace("onTouchMove : " + index + " , " + x + " , " + y + " , " + dx + " , " + dy);
	}

	inline function updateTouch (index:Int, x:Int, y:Int)
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
				dy : 0,
				state : InputState.NONE
			});
		}
	}

	inline public static function isDown (index:Int=0)
	{
		return (touches.exists(index)) ? touches[index].state == InputState.DOWN : false;
	}

	inline public static function isHeld (index:Int=0)
	{
		return (touches.exists(index)) ? touches[index].state == InputState.HELD : false;
	}

	inline public static function isUp (index:Int=0)
	{
		return (touches.exists(index)) ? touches[index].state == InputState.UP : false;
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
		Surface.get().notify(func, null, null);
	}

	inline public static function notifyEnd (func:Int->Int->Int->Void)
	{
		Surface.get().notify(null, func, null);
	}

	inline public static function notifyMove (func:Int->Int->Int->Void)
	{
		Surface.get().notify(null, null, func);
	}

	inline public static function removeStart (func:Int->Int->Int->Void)
	{
		Surface.get().remove(func, null, null);
	}

	inline public static function removeEnd (func:Int->Int->Int->Void)
	{
		Surface.get().remove(null, func, null);
	}

	inline public static function removeMove (func:Int->Int->Int->Void)
	{
		Surface.get().remove(null, null, func);
	}
}