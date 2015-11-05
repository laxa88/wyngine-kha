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
		/**
			NOTE: The DOWN and UP states sometimes happen in the
			same update cycle, and sometimes in not (for mac trackpad),
			so sometimes the "held" key will not trigger if both
			DOWN and UP states happen in the same frame.
		 */

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

		// These are screenX/screenY
		WynMouse.x = x;
		WynMouse.y = y;

		// For each camera, trigger the update the mouse coordinates accordingly.
		for (camera in Wyngine.G.cameras)
		{
			var mouseData = getMousePositions(camera, x, y);
			camera.onMouseStart(mouseData);
		}
	}

	function onMouseMove (x:Int, y:Int, dx:Int, dy:Int) // github latest
	// function onMouseMove (x:Int, y:Int) // haxelib 15.10
	{
		// Only callback for mousemove if we manually listen for it.
		for (listener in _mouseMoveListeners)
			listener(x,y,dx,dy);

		WynMouse.x = x;
		WynMouse.y = y;

		// For each camera, trigger the update the mouse coordinates accordingly.
		for (camera in Wyngine.G.cameras)
		{
			var mouseData = getMousePositions(camera, x, y);
			camera.onMouseMove(mouseData);
		}
	}

	function onMouseEnd (index:Int, x:Int, y:Int)
	{
		_mouseReleased[index] = BEGIN;

		WynMouse.x = x;
		WynMouse.y = y;

		// For each camera, trigger the update the mouse coordinates accordingly.
		for (camera in Wyngine.G.cameras)
		{
			var mouseData = getMousePositions(camera, x, y);
			camera.onMouseEnd(mouseData);
		}
	}

	inline function getMousePositions (camera:WynCamera, x:Int, y:Int) : WynCamera.MouseData
	{
		// TODO
		// cameraX/Y (position relative to top-left origin of camera)

		// windowX/Y (raw window mouse position)
		// screenX/Y (scaled window mouse position)
		// camWindowX/Y (raw camera mouse position)
		// camScreenX/Y (scaled camera mouse position)
		// worldX/Y (mouse position in game world, based on current camera, offset by camera scroll)

		// Example:
		// game = {width:640, height:480, zoom:2}
		// camera = {x:200, y:100, width:320, height:240, scrollX:50, scrollY:70}
		// AND mouse clicked in screen = {x:350, y:300}
		// THEN:
		// window x,y = {350, 300} (original value)
		// screen x,y = {175, 150} (window / camera.zoom)
		// camWindow x,y = {150, 200} (window - camera.pos)
		// camScreen x,y = {75, 100} (screen - (camera.pos / camera.zoom))
		// world x,y (camera) = {125, 170} (camScreen + scroll)


		// NOTE: doesn't include camera shake!
		return {
			windowX : Math.round(x),
			windowY : Math.round(y),
			screenX : Math.round(x / camera.zoom),
			screenY : Math.round(y / camera.zoom),
			camWindowX : Math.round(x - camera.x),
			camWindowY : Math.round(y - camera.y),
			camScreenX : Math.round((x - camera.x) / camera.zoom),
			camScreenY : Math.round((y - camera.y) / camera.zoom),
			worldX : Math.round(((x - camera.x) / camera.zoom) + camera.scrollX),
			worldY : Math.round(((y - camera.y) / camera.zoom) + camera.scrollY)
		};
	}

	function onMouseWheel (delta:Int)
	{
		// Not working, based on last kha commit I checked
		trace("### onMouseWheel : " +delta);
	}
}