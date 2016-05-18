package wyn.manager;

import kha.Sound;
import kha.audio1.Audio;
import kha.audio1.AudioChannel;

typedef AudioData = {
	var channel:AudioChannel;
	var loopCount:Int;
	var loopCounter:Int;
}

class WynAudio extends WynManager
{
	static var sounds:Map<Sound, AudioData>;

	public function new ()
	{
		super();

		sounds = new Map<Sound, AudioData>();
	}

	override public function update ()
	{
		// loop music manually
		for (key in sounds.keys())
		{
			if (sounds[key].channel.finished)
			{
				if (sounds[key].loopCounter < sounds[key].loopCount)
				{
					sounds[key].channel = Audio.play(key, true);
					sounds[key].loopCounter += 1;
				}
				else
				{
					// remove from list when done
					sounds.remove(key);
				}
			}
		}
	}

	override public function reset ()
	{
		super.reset();

		for (key in sounds.keys())
		{
			sounds[key].channel.stop();
			sounds.remove(key);
		}
	}



	public static function playSound (file:Sound, volume:Float=1.0) : AudioChannel
	{
		var channel = Audio.play(file, false);
		channel.stop();
		channel.play();
		channel.volume = volume;

		// Sounds are fire-and-forget

		return channel;
	}

	public static function playMusic (file:Sound, volume:Float=1.0, loopCount:Int=0) : AudioChannel
	{
		var channel = Audio.play(file, true);
		channel.volume = volume;

		// If music already exists, overwrite it
		if (sounds.exists(file))
			sounds[file].channel.stop();

		// Store reference to music channel for editing later
		sounds.set(file, {
			channel : channel,
			loopCount : loopCount,
			loopCounter : 1
		});

		return channel;
	}

	public static function stopMusic (file:Sound)
	{
		if (sounds.exists(file))
		{
			sounds[file].channel.stop();
			sounds.remove(file);
		}
	}
}