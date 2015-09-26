package wy;

import kha.Image;

class WyAnimation
{
	// NOTES
	// - Animator controls a list of Animations
	// - Animator belongs to a Sprite
	// - Sprite may have a default image
	// - Animation may come from more than one image 

	public var _parent:WyAnimator;
	public var _name:String;
	public var _frames:Array<Int>;
	// public var _currIndex:Int = 0;
	public var _fps:Int = 6; // purposely slow so we know it's default
	// public var _currFrame:Int = 0;
	// public var _numFrame:Int = 0;
	// public var _finished:Bool = true;
	// public var _paused:Bool = true;
	public var _loop:Bool = true;
	// private var _frameElapsed:Float = 0.0;

	public function new (parent:WyAnimator, name:String, frames:Array<Int>, fps:Int, loop:Bool)
	{
		_parent = parent;
		_name = name;
		_frames = frames;
		_fps = fps;
		_loop = loop;
	}
	public function update (elapsed:Float) {}
	public function destroy () {}



	public function isLoop ():Bool
	{
		return _loop;
	}
	public function getFrameLength ():Int
	{
		return _frames.length;
	}
	public function getFrameIndex (index:Int):Int
	{
		// Gets the actual spritesheet's frame index
		// based on current animation's index
		// e.g. _frames = [0,3,5,4]
		// thus, _frames[2] = 5

		if (index < 0)
			index = 0;

		if (index >= _frames.length)
			return 0; // return first index as default if fail
		else
			return _frames[index];
	}
}