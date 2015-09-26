package wy;

class WyAnimator
{
	public var _owner:WySprite;
	// public var _name:String;
	public var _paused:Bool;
	public var _reverse:Bool;
	// public var _finished:Bool;
	public var _currAnim:WyAnimation;
	public var _frameIndex:Int = -1;
	private var _animations:Map<String, WyAnimation>;
	private var _frameElapsed:Float = 0;
	private var _frameRate:Float = 1/60;
	private var _speedScale:Float = 1;



	public function new (sprite:WySprite)
	{
		_owner = sprite;
		_animations = new Map<String, WyAnimation>();
	}
	public function destroy ()
	{
		for (item in _animations)
			item.destroy();

		_owner = null;
		_animations = null;
	}
	public function update (elapsed:Float)
	{
		// This keeps track of frame being played for
		// the current animation. The animation itself
		// only stores data.

		if (!_paused)
		{
			_frameElapsed += elapsed * _speedScale;
			if (_frameElapsed > _frameRate)
			{
				if (_reverse)
					_frameIndex--;
				else
					_frameIndex++;

				// Ensures that frames paused for too long are skipped.
				while (_frameElapsed > _frameRate)
					_frameElapsed -= _frameRate;
			}

			if (_frameIndex < 0)
				_frameIndex = _currAnim.getFrameLength() - 1;
			if (_frameIndex >= _currAnim.getFrameLength())
				_frameIndex = 0;
		}
	}



	public function add(name:String, frames:Array<Int>, fps:Int=30, loop:Bool=true):Void
	{
		// NOTE:
		// - frames store the index for the animation
		// - e.g. frames = [0,3,5,4]
		// - this means the animation plays frames 0-3-5-4 in order.

		var anim:WyAnimation = new WyAnimation(this, name, frames, fps, loop);
		_animations[name] = anim;

		if (_currAnim == null)
			_currAnim = anim;
	}
	public function play(name:String, reset:Bool=false)
	{
		// NOTE:
		// - for now, playing a new animation will always reset

		if (_currAnim._name == name)
		{
			// Reset is flagged, otherwise ignore
			if (reset)
			{
				_frameIndex = 0;
				_frameRate = 1.0 / _currAnim._fps;
			}
		}
		else
		{
			if (_animations.exists(name))
			{
				_frameIndex = 0;
				_currAnim = _animations[name];
				_frameRate = 1.0 / _currAnim._fps;
			}
			else
			{
				throw "Animation '"+name+"' doesn't exist.";
			}
		}
	}
	public function pause ()
	{
		_paused = true;
	}
	public function resume ()
	{
		_paused = false;
	}
	public function setReverse (val:Bool)
	{
		_reverse = val;
	}
	public function setSpeedScale (scale:Float)
	{
		_speedScale = scale;
	}
	public function addSpeedScale (scale:Float)
	{
		_speedScale += scale;
	}
	public function getFrameIndex ():Int
	{
		// Returns the current animation's frame index in the sprite sheet
		return _currAnim.getFrameIndex(_frameIndex);
	}
}