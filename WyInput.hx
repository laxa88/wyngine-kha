package wy;

import kha.Key;
import kha.input.Keyboard;

class WyInput
{
	public static function get():WyInput { return instance; }
	private static var instance: WyInput;

	private static var _keysPressed:Map<Key, Bool>;
	private static var _charsPressed:Map<String, Bool>;
	private static var _keysHeld:Map<Key, Bool>;
	private static var _charsHeld:Map<String, Bool>;
	private static var _keysReleased:Map<Key, Bool>;
	private static var _charsReleased:Map<String, Bool>;



	public function new ()
	{
		_keysPressed = new Map<Key, Bool>();
		_charsPressed = new Map<String, Bool>();
		_keysHeld = new Map<Key, Bool>();
		_charsHeld = new Map<String, Bool>();
		_keysReleased = new Map<Key, Bool>();
		_charsReleased = new Map<String, Bool>();

		Keyboard.get().notify(onKeyDown, onKeyUp);

		instance = this;
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
	public static function isKeyDown (key:Key, char:String=""):Bool
	{
		if (key == Key.CHAR)
			return _charsPressed[char];
		else
			return _keysPressed[key];
	}
	public static function isKey (key:Key, char:String=""):Bool
	{
		if (key == Key.CHAR)
			return _charsHeld[char];
		else
			return _keysHeld[key];
	}
	public static function isKeyUp (key:Key, char:String=""):Bool
	{
		if (key == Key.CHAR)
			return _charsReleased[char];
		else
			return _keysReleased[key];
	}



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
		//Wy.log("key up : " + key + " , " + char);
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
}