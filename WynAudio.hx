package wyn;

import kha.Assets;
import kha.Sound;
import kha.audio1.Audio;
import kha.audio1.AudioChannel;

class WynAudio
{
	public static var instance:WynAudio;
	private var _sounds:Map<Sound, AudioChannel>;



	public function new ()
	{
		if (instance == null)
		{
			_sounds = new Map<Sound, AudioChannel>();
			instance = this;
		}
		else
		{
			_reset();
		}
	}

	/**
	 * These public functions should not be called manually,
	 * use the static methods instead.
	 */

	public function _reset ()
	{
		// Just stop the sounds for now
		for (item in _sounds)
			item.stop();

		_sounds = new Map<Sound, AudioChannel>();
	}

	public function _setVolume (file:Sound, volume:Float)
	{
		if (_sounds[file] != null)
			_sounds[file].volume = volume;
	}
	public function _pause (file:Sound)
	{
		if (_sounds[file] != null)
			_sounds[file].pause();
	}
	public function _stop (file:Sound)
	{
		if (_sounds[file] != null)
			_sounds[file].stop();
	}
	public function _play (file:Sound, volume:Float=1.0, ?loop:Bool, ?stream:Bool, restart:Bool=true) : AudioChannel
	{
		if (_sounds[file] == null)
		{
			// Create new channel if it doesn't exist, and store it in dictionary.
			var channel:AudioChannel = Audio.play(file, loop, stream);
			channel.volume = volume;
			_sounds[file] = channel;
		}
		else
		{
			if (_sounds[file].finished)
			{
				// If the music has finished, then just play a new channel and overwrite the slot.
				var channel:AudioChannel = Audio.play(file, loop, stream);
				channel.volume = volume;
				_sounds[file] = channel;
			}
			else
			{
				// Otherwise, try to resume.
				_sounds[file].play();
			}
		}

		// Return the AudioChannel for further tinkering, if possible.
		return _sounds[file];
	}
	public function _playOnce (file:Sound, volume:Float=1.0) : AudioChannel
	{
		// Plays a new sound without storing into dictionary.
		var channel:AudioChannel = Audio.play(file);
		channel.volume = volume;

		return channel;
	}

	/**
	 * These public static methods allow you to easily call the API, e.g.
	 * 		WynAudio.init()
	 * 		WynAudio.reset()
	 * 		WynAudio.playMusic()
	 * 		... and so on
	 */

	public static function init ()
	{
		instance = new WynAudio();
	}
	public static function reset ()
	{
		instance._reset();
	}
	
	public static function setVolume (file:Sound, volume:Float)
	{
		instance._setVolume(file, volume);
	}
	public static function pause (file:Sound)
	{
		instance._pause(file);
	}
	public static function stop (file:Sound)
	{
		instance._stop(file);
	}
	public static function play (file:Sound, volume:Float=1.0, ?loop:Bool, ?stream:Bool, restart:Bool=true) : AudioChannel
	{
		return instance._play(file, restart, volume, loop, stream);
	}
	public static function playOnce (file:Sound, volume:Float=1.0) : AudioChannel
	{
		return instance._playOnce(file, volume);
	}
}