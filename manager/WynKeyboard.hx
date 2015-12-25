package wyn.manager;

import kha.input.Keyboard;
import kha.Key;

class WynKeyboard extends WynManager
{
	// Taken from:
	// https://github.com/RafaelOliveira/LD34

	static var keysDown:Map<String, Bool>;
	static var keysHeld:Map<String, Bool>;
	static var keysUp:Map<String, Bool>;
	static var keysCount:Int = 0;
	static var keysJustPressed:Bool = false;

	static var downListener:Array<String->Void>;
	static var upListener:Array<String->Void>;

	public function new ()
	{
		super();

		Keyboard.get().notify(onKeyDown, onKeyUp);

		keysDown = new Map<String, Bool>();
		keysHeld = new Map<String, Bool>();
		keysUp = new Map<String, Bool>();

		downListener = [];
		upListener = [];
	}

	override public function update ()
	{
		for (key in keysDown.keys())
			keysDown.remove(key);

		for (key in keysUp.keys())
			keysUp.remove(key);

		keysJustPressed = false;
	}

	override public function reset ()
	{
		super.reset();

		for (key in keysDown.keys())
			keysDown.remove(key);

		for (key in keysHeld.keys())
			keysHeld.remove(key);

		for (key in keysUp.keys())
			keysUp.remove(key);

		while (downListener.length > 0)
			downListener.pop();

		while (upListener.length > 0)
			upListener.pop();
	}



	function onKeyDown (key:Key, char:String)
	{
		for (listener in downListener)
			listener(key.getName().toLowerCase());

		// trace("down : " + key + " , " + char);

		if (key == Key.CHAR)
		{
			keysDown.set(char, true);
			keysHeld.set(char, true);
		}
		else
		{
			keysDown.set(key.getName().toLowerCase(), true);
			keysHeld.set(key.getName().toLowerCase(), true);
		}

		keysCount++;

		keysJustPressed = true;
	}

	function onKeyUp (key:Key, char:String)
	{
		for (listener in upListener)
			listener(key.getName().toLowerCase());

		// trace("up : " + key + " , " + char);

		if (key == Key.CHAR)
		{
			keysUp.set(char, true);
			keysHeld.set(char, false);
		}
		else
		{
			keysUp.set(key.getName().toLowerCase(), true);
			keysHeld.set(key.getName().toLowerCase(), false);
		}

		keysCount--;
	}

	inline public static function isDown (key:String) : Bool
	{
		return keysDown.exists(key);
	}

	inline public static function isHeld (key:String) : Bool
	{
		return keysHeld.get(key);
	}

	inline public static function isUp (key:String) : Bool
	{
		return keysUp.exists(key);
	}

	inline public static function isAny () : Bool
	{
		return (keysCount > 0);
	}

	inline public static function isAnyDown () : Bool
	{
		return keysJustPressed;
	}

	inline public static function notifyDown (func:String->Void)
	{
		if (downListener.indexOf(func) == -1)
			downListener.push(func);
	}

	inline public static function notifyUp (func:String->Void)
	{
		if (upListener.indexOf(func) == -1)
			upListener.push(func);
	}

	inline public static function removeDown (func:String->Void)
	{
		downListener.remove(func);
	}

	inline public static function removeUp (func:String->Void)
	{
		upListener.remove(func);
	}
}