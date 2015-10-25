package wyn;

import kha.Loader;
import kha.Music;
import kha.Sound;
import kha.audio1.Audio;
import kha.audio1.MusicChannel;
import kha.audio1.SoundChannel;

class WynAudio
{
	public static var instance:WynAudio;
	private var _musics:Map<String, Music>;
	private var _sounds:Map<String, Sound>;
	private var _bgm:Map<String, MusicChannel>;



	public function new ()
	{
		if (instance == null)
		{
			_musics = new Map<String, Music>();
			_sounds = new Map<String, Sound>();
			_bgm = new Map<String, MusicChannel>();
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
		for (item in _musics)
			item.unload();

		for (item in _sounds)
			item.unload();

		for (item in _bgm)
			item.stop();

		_musics = new Map<String, Music>();
		_sounds = new Map<String, Sound>();
		_bgm = new Map<String, MusicChannel>();
	}

	public function _playMusic (name:String, volume:Float=1.0, repeat:Bool=true)
	{
		// TODO volume doesn't work

		if (_musics[name] == null)
			_musics[name] = Loader.the.getMusic(name);

		if (_bgm[name] == null)
		{
			var channel:MusicChannel = Audio.playMusic(_musics[name], repeat);
			channel.volume = 0.1;
			_bgm[name] = channel;
		}
		else
		{
			_bgm[name].play();
		}
	}

	public function _setMusicVolume (name:String, volume:Float)
	{
		// TODO volume doesn't work
		
		if (_bgm[name] != null)
		{
			_bgm[name].volume = volume;
			_bgm[name].play();
		}
	}

	public function _pauseMusic (name:String)
	{
		if (_bgm[name] != null)
			_bgm[name].pause();
	}

	public function _stopMusic (name:String)
	{
		if (_bgm[name] != null)
			_bgm[name].stop();
	}

	public function _playSound (name:String, volume:Float=1.0)
	{
		if (_sounds[name] == null)
			_sounds[name] = Loader.the.getSound(name);

		var channel:SoundChannel = Audio.playSound(_sounds[name]);
		channel.volume = volume;
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
	public static function playMusic (name:String, volume:Float=1.0, repeat:Bool=true)
	{
		instance._playMusic(name, volume, repeat);
	}
	public static function setMusicVolume (name:String, volume:Float)
	{
		instance._setMusicVolume(name, volume);
	}
	public static function pauseMusic (name:String)
	{
		instance._pauseMusic(name);
	}
	public static function stopMusic (name:String)
	{
		instance._stopMusic(name);
	}
	public static function playSound (name:String, volume:Float=1.0)
	{
		instance._playSound(name, volume);
	}
}