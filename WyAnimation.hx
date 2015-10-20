package wy;

import kha.Image;

class WyAnimation
{
	public var _animator:WyAnimator;
	public var _name:String;
	public var _frames:Array<Int>;
	public var _fps:Int = 6; // 6 frames per second
	public var _loop:Bool = true;



	public function new (parent:WyAnimator, name:String, frames:Array<Int>, fps:Int, loop:Bool)
	{
		_animator = parent;
		_name = name;
		_frames = frames;
		_fps = fps;
		_loop = loop;
	}

	public function getFrameIndex (index:Int):Int
	{
		// Gets the actual spritesheet's frame index
		// based on current animation's index
		// e.g. frames = [0,3,5,4]
		// thus, frames[2] = 5

		if (_frames.length <= 0)
			return 0;

		// Loops the index if out of range,
		// e.g. length = 4, index = -1, returns 3
		// e.g. length = 4, index = 4, returns 0
		while (index < 0)
			index += _frames.length;
		while (index >= _frames.length)
			index -= _frames.length;

		return _frames[index];
	}
}