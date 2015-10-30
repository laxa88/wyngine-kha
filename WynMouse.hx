package wyn;

import kha.input.Mouse;

class WynMouse
{
	/**
	 kha.input.Mouse already does everything out of the box.
	 This class is just a wrapper to handle Bool states for
	 mouseDown, mouseHeld and mouseRelease.

	 For other stuff, use kha.Mouse as well, such as:
	 	notify
	 	remove
	 	lock
	 	unlock
	 	canLock
	 	isLocked
	 	notifyOfLockChange
	 	removeFromLockChange
	 */

	public static inline var BEGIN:Int = 0;
	public static inline var ACTIVE:Int = 1;
	public static inline var END:Int = 2;

	public static var instance:WynMouse;
	public static var x(default, null):Int = 0;
	public static var y(default, null):Int = 0;

	private var _mousePressed:Map<Int, Int>;
	private var _mouseHeld:Map<Int, Int>;
	private var _mouseReleased:Map<Int, Int>;
	private var _mouseMoveListeners:Array<Int->Int->Int->Int->Void>;



	public function new ()
	{
		// Internal listeners to get mouse states only.
		// To handle mouse events manually, do
		Mouse.get().notify(onMouseStart, onMouseEnd, onMouseMove, onMouseWheel);

		_mousePressed = new Map<Int, Int>();
		_mouseHeld = new Map<Int, Int>();
		_mouseReleased = new Map<Int, Int>();
		_mouseMoveListeners = new Array<Int->Int->Int->Int->Void>();
	}

	public function update ()
	{
		// NOTE: The DOWN and UP states sometimes happen in the
		// same update cycle, and sometimes in not (for mac trackpad),
		// so sometimes the "held" key will not trigger if both
		// DOWN and UP states happen in the same frame.

		for (key in _mousePressed.keys())
		{
			// When mouse is down, held state is also assumed to be down.
			if (_mousePressed[key] == BEGIN)
			{
				_mousePressed[key] = ACTIVE;
				_mouseHeld[key] = BEGIN;
			}
			else
			{
				_mousePressed[key] = END;
			}

			// When mouse is held, activate it for isMouse() to trigger
			if (_mouseHeld[key] == BEGIN)
				_mouseHeld[key] = ACTIVE;

			// When mouse is released, held state is also assumed to be released
			if (_mouseReleased[key] == BEGIN)
			{
				_mouseHeld[key] = END;
				_mouseReleased[key] = ACTIVE;
			}
			else
				_mouseReleased[key] = END;
		}
	}

	public function destroy ()
	{
		// NOTE: there's no remove() for Sensor listeners

		_mousePressed = null;
		_mouseHeld = null;
		_mouseReleased = null;
		_mouseMoveListeners = [];

		Mouse.get().remove(onMouseStart, onMouseEnd, onMouseMove, onMouseWheel);
	}

	public static function init ()
	{
		instance = new WynMouse();
	}

	/**
	 * Listen for mouse movement within the game
	 */
	public static function notifyMove (listener:Int->Int->Int->Int->Void)
	{
		if (instance._mouseMoveListeners.indexOf(listener) == -1)
			instance._mouseMoveListeners.push(listener);
	}
	public static function removeMove (listener:Int->Int->Int->Int->Void)
	{
		instance._mouseMoveListeners.remove(listener);
	}

	/**
	 * These public functions should not be called manually,
	 * use the static methods instead.
	 */

	public function _isMouseDown (index:Int) : Bool
	{
		if (_mousePressed.exists(index) && _mousePressed[index] == ACTIVE)
				return true;

		return false;
	}
	public function _isMouse (index:Int) : Bool
	{
		if (_mouseHeld.exists(index) && _mouseHeld[index] == ACTIVE)
				return true;

		return false;
	}
	public function _isMouseUp (index:Int) : Bool
	{
		if (_mouseReleased.exists(index) && _mouseReleased[index] == ACTIVE)
			return true;

		return false;
	}

	/**
	 * Similar to WynInput
	 */

	public static function isMouseDown (index:Int) : Bool
	{
		return instance._isMouseDown(index);
	}
	public static function isMouse (index:Int) : Bool
	{
		return instance._isMouse(index);
	}
	public static function isMouseUp (index:Int) : Bool
	{
		return instance._isMouseUp(index);
	}



	function onMouseStart (index:Int, x:Int, y:Int)
	{
		_mousePressed[index] = BEGIN;
		_mouseHeld[index] = BEGIN;

		WynMouse.x = x;
		WynMouse.y = y;
	}

	function onMouseMove (x:Int, y:Int, dx:Int, dy:Int)
	{
		// Only callback for mousemove if we manually listen for it.
		for (listener in _mouseMoveListeners)
			listener(x,y,dx,dy);

		WynMouse.x = x;
		WynMouse.y = y;
	}

	function onMouseEnd (index:Int, x:Int, y:Int)
	{
		_mouseReleased[index] = BEGIN;

		WynMouse.x = x;
		WynMouse.y = y;
	}

	function onMouseWheel (delta:Int)
	{
		trace("### onMouseWheel : " +delta);
	}
}