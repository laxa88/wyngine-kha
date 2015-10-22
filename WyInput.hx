package wy;

import kha.Key;
import kha.input.Keyboard;

class WyInput
{
	/**
		This class is modular and can be used stand-alone.
		
		Just instantiate a WyInput in your game, then call
		the update() to keep track of the data. then call
		the following static methods whenever you want:
		- isKeyDown
		- isKey
		- isKeyUp
	*/

	public static var instance:WyInput;
	private var _keysPressed:Map<Key, Bool>;
	private var _charsPressed:Map<String, Bool>;
	private var _keysHeld:Map<Key, Bool>;
	private var _charsHeld:Map<String, Bool>;
	private var _keysReleased:Map<Key, Bool>;
	private var _charsReleased:Map<String, Bool>;

	/**
	* These instance functions should never be used directly,
	* because we use the static methods further below.
	*/

	public function new ()
	{
		_keysPressed = new Map<Key, Bool>();
		_charsPressed = new Map<String, Bool>();
		_keysHeld = new Map<Key, Bool>();
		_charsHeld = new Map<String, Bool>();
		_keysReleased = new Map<Key, Bool>();
		_charsReleased = new Map<String, Bool>();

		Keyboard.get().notify(onKeyDown, onKeyUp);
	}

	public function update ()
	{
		for (key in _keysPressed.keys())
		{
			if (_keysPressed[key])
			{
				if (_keysHeld[key])
					_keysPressed[key] = false;
				else
					_keysHeld[key] = true;
			}

			if (_keysReleased[key])
			{
				if (_keysHeld[key])
					_keysHeld[key] = false;
				else
					_keysReleased[key] = false;
			}
		}

		for (char in _charsPressed.keys())
		{
			if (_charsPressed[char])
			{
				if (_charsHeld[char])
					_charsPressed[char] = false;
				else
					_charsHeld[char] = true;
			}

			if (_charsReleased[char])
			{
				if (_charsHeld[char])
					_charsHeld[char] = false;
				else
					_charsReleased[char] = false;
			}
		}
	}

	public function destroy ()
	{
		_keysPressed = null;
		_charsPressed = null;
		_keysHeld = null;
		_charsHeld = null;
		_keysReleased = null;
		_charsReleased = null;
		Keyboard.get().remove(onKeyDown, onKeyUp);
	}

	/**
	* These are callbacks for kha.Keyboard keyDown and keyUp events.
	* Callbacks will be processed, and stored into WyInput's 
	* char or key's press/held/released boolean arrays.
	*/

	private function onKeyDown (key:Key, char:String):Void
	{
		// Wy.log("key down : " + key + " , " + char);
		if (key == Key.CHAR)
		{
			_charsPressed[char] = true;
			_charsReleased[char] = false;
		}
		else
		{
			_keysPressed[key] = true;
			_keysReleased[key] = false;
		}
	}

	private function onKeyUp (key:Key, char:String):Void
	{
		// Wy.log("key up : " + key + " , " + char);
		if (key == Key.CHAR)
		{
			_charsPressed[char] = false;
			_charsReleased[char] = true;
		}
		else
		{
			_keysPressed[key] = false;
			_keysReleased[key] = true;
		}
	}

	/**
	* These are instance methods, accessed from the static variable "instance"
	*/

	public function _isKeyDown (key:Key, char:String=""):Bool
	{
		if (key == Key.CHAR)
			return _charsPressed[char];
		else
			return _keysPressed[key];
	}

	public function _isKey (key:Key, char:String=""):Bool
	{
		if (key == Key.CHAR)
			return _charsHeld[char];
		else
			return _keysHeld[key];
	}

	public function _isKeyUp (key:Key, char:String=""):Bool
	{
		if (key == Key.CHAR)
			return _charsReleased[char];
		else
			return _keysReleased[key];
	}

	/**
	* Allows usage like WyInput.isKeyDown(...);
	*/

	public static function init ()
	{
		instance = new WyInput();
	}

	public static function isKeyDown (key:Key, char:String=""):Bool
	{
		return instance._isKeyDown(key, char);
	}

	public static function isKey (key:Key, char:String=""):Bool
	{
		return instance._isKey(key, char);
	}

	public static function isKeyUp (key:Key, char:String=""):Bool
	{
		return instance._isKeyUp(key, char);
	}
}