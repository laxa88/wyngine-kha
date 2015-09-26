package wy;

import kha.Loader;
import kha.Music;
import kha.Sound;
import kha.audio1.Audio;
import kha.audio1.MusicChannel;
import kha.audio1.SoundChannel;

class WyAudio
{
	public static function get():WyAudio { return instance; }
	private static var instance: WyAudio;

	private static var _musics:Map<String, Music>;
	private static var _sounds:Map<String, Sound>;
	private static var _bgm:Map<String, MusicChannel>;



	public function new ()
	{
		_musics = new Map<String, Music>();
		_sounds = new Map<String, Sound>();
		_bgm = new Map<String, MusicChannel>();

		instance = this;
	}



	public static function reset ()
	{
		for (item in _musics)
			item.unload();

		for (item in _sounds)
			item.unload();

		_musics = new Map<String, Music>();
		_sounds = new Map<String, Sound>();
		_bgm = new Map<String, MusicChannel>();
	}
	public static function playMusic (name:String, volume:Float=1.0, repeat:Bool=true)
	{
		// TODO volume doesn't work

		if (_musics[name] == null)
			_musics[name] = Loader.the.getMusic(name);

		if (_bgm[name] == null)
		{
			var channel:MusicChannel = Audio.playMusic(_musics[name], repeat);
			channel.volume = volume;
			_bgm[name] = channel;
		}
		else
		{
			_bgm[name].play();
		}
	}
	public static function setMusicVolume (name:String, volume:Float)
	{
		// TODO volume doesn't work
		if (_bgm[name] != null)
		{
			_bgm[name].volume = volume;
			_bgm[name].play();
		}
	}
	public static function pauseMusic (name:String)
	{
		if (_bgm[name] != null)
			_bgm[name].pause();
	}
	public static function stopMusic (name:String)
	{
		if (_bgm[name] != null)
			_bgm[name].stop();
	}
	public static function playSound (name:String, volume:Float=1.0)
	{
		if (_sounds[name] == null)
			_sounds[name] = Loader.the.getSound(name);

		Audio.playSound(_sounds[name]);
	}
}