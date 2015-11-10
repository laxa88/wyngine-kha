package wyn;

import kha.input.Sensor;
import kha.input.Surface;
import kha.input.SensorType;

typedef TouchData = {
	var index:Int;
	var x:Int;
	var y:Int;
	var on:Bool;
}

class WynTouch
{
	// TODO
	// Gyro and accelerometer

	public static var instance:WynTouch;
	private var _touchPressed:Map<Int, TouchData>;
	private var _touchHeld:Map<Int, TouchData>;
	private var _touchReleased:Map<Int, TouchData>;



	public function new ()
	{
		// NOTE: Only mobile devices would have this.
		// var accel = Sensor.get(SensorType.Accelerometer);
		// if (accel != null)
		// 	accel.notify(onAcceleroUpdate);

		// var gyro = Sensor.get(SensorType.Gyroscope);
		// if (gyro != null)
		// 	gyro.notify(onGyroUpdate);

		var surface = Surface.get();
		if (surface != null)
			surface.notify(onTouchStart, onTouchEnd, onTouchMove);

		_touchPressed = new Map<Int, TouchData>();
		_touchHeld = new Map<Int, TouchData>();
		_touchReleased = new Map<Int, TouchData>();
	}

	public function update ()
	{
		// NOTE: Similar to WynInput
		for (key in _touchPressed.keys())
		{
			if (_touchPressed[key].on)
			{
				if (_touchHeld[key].on)
					_touchPressed[key].on = false;
				else
					_touchHeld[key].on = true;
			}

			if (_touchReleased[key].on)
			{
				if (_touchHeld[key].on)
					_touchHeld[key].on = false;
				else
					_touchReleased[key].on = false;
			}
		}
	}

	public function destroy ()
	{
		// NOTE: there's no remove() for Sensor listeners

		_touchPressed = null;
		_touchHeld = null;
		_touchReleased = null;

		Surface.get().remove(onTouchStart, onTouchEnd, onTouchMove);
	}

	public static function init ()
	{
		instance = new WynTouch();
	}

	// function onGyroUpdate (x:Float, y:Float, z:Float)
	// {
	// 	trace("onGyroUpdate : " +x+","+y+","+z);
	// }

	// function onAcceleroUpdate (x:Float, y:Float, z:Float)
	// {
	// 	trace("onAcceleroUpdate : " +x+","+y+","+z);
	// }

	/**
	 * These public functions should not be called manually,
	 * use the static methods instead.
	 */

	public function _isTouchDown (index:Int) : Bool
	{
		if (_touchPressed.exists(index) && _touchPressed[index].on)
			return true;
		else
			return false;
	}
	public function _isTouch (index:Int) : Bool
	{
		if (_touchHeld.exists(index) && _touchHeld[index].on)
			return true;
		else
			return false;
	}
	public function _isTouchUp (index:Int) : Bool
	{
		if (_touchReleased.exists(index) && _touchReleased[index].on)
			return true;
		else
			return false;
	}

	/**
	 * Similar to WynInput
	 */

	public static function isTouchDown (index:Int) : Bool
	{
		return instance._isTouchDown(index);
	}
	public static function isTouch (index:Int) : Bool
	{
		return instance._isTouch(index);
	}
	public static function isTouchUp (index:Int) : Bool
	{
		return instance._isTouchUp(index);
	}



	function onTouchStart (index:Int, x:Int, y:Int)
	{
		// trace("onTouchStart : " +index+","+x+","+y);

		_touchPressed.set(index, { index:index, x:x, y:y, on:true });
		_touchHeld.set(index, { index:index, x:x, y:y, on:false });
		_touchReleased.set(index, { index:index, x:x, y:y, on:false });
	}

	function onTouchMove (index:Int, x:Int, y:Int)
	{
		// trace("onTouchMove : " +index+","+x+","+y);

		// Update the held position
		_touchHeld[index].x = x;
		_touchHeld[index].y = x;
		_touchHeld[index].on = true;
	}

	function onTouchEnd (index:Int, x:Int, y:Int)
	{
		// trace("onTouchEnd : " +index+","+x+","+y);

		// Note: let the _touchRelease toggle the _touchMove in update() naturally.
		_touchPressed.set(index, { index:index, x:x, y:y, on:false });
		_touchReleased.set(index, { index:index, x:x, y:y, on:true });
	}
}