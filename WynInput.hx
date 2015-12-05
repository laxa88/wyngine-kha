package wyn;

import kha.Key;
import kha.input.Keyboard;

class WynInput
{
	public static var instance:WynInput;

	private var _keysPressed:Map<Key, Bool>;
	private var _charsPressed:Map<String, Bool>;
	private var _keysHeld:Map<Key, Bool>;
	private var _charsHeld:Map<String, Bool>;
	private var _keysReleased:Map<Key, Bool>;
	private var _charsReleased:Map<String, Bool>;

	/**
	 * These should be handled by Wyngine automatically.
	 */

	public function new ()
	{
		// Add event
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
	 * Callbacks will be processed, and stored into WynInput's 
	 * char or key's press/held/released boolean arrays.
	 */

	private function onKeyDown (key:Key, char:String):Void
	{
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
	 * These public functions should not be called manually,
	 * use the static methods instead.
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
	 * These public static methods allow you to easily call the API, e.g.
	 * 		WynInput.init()
	 * 		WynInput.isKeyDown()
	 * 		... and so on
	 */

	public static function init ()
	{
		// Init instance
		instance = new WynInput();

		// Reset all notifier arrays
		reset();
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
	public static function reset ()
	{
		// When changing screens or opening subscreen, this is used
		// so that previous inputs do not interfere in the new screen.
		instance._keysPressed = new Map<Key, Bool>();
		instance._charsPressed = new Map<String, Bool>();
		instance._keysHeld = new Map<Key, Bool>();
		instance._charsHeld = new Map<String, Bool>();
		instance._keysReleased = new Map<Key, Bool>();
		instance._charsReleased = new Map<String, Bool>();
	}
}