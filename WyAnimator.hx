package wy;

class WyAnimator
{
	public var _parent:WyObject;
	public var _animations:Map<String, WyAnimation>;
	public var _currAnim:WyAnimation;
	public var _reverse:Bool;
	public var _speed:Float;
	public var _paused:Bool;
	var _frameElapsed:Float;
	var _frameRate:Float;
	var _frameIndex:Int; // frame's index in current animation, not global index



	public function new (obj:WyObject)
	{
		_parent = obj;

		init();
	}

	public function init ()
	{
		_animations = new Map<String, WyAnimation>();
		_currAnim = null;
		_reverse = false;
		_speed = 1.0;
		_paused = false;

		_frameElapsed = 0.0;
		_frameRate = 1/60;
		_frameIndex = 0;
	}

	public function update (dt:Float)
	{
		// This keeps track of frame being played for
		// the current animation. The animation itself
		// only stores data.

		// This method updates frame, affected by dt.
		// If dt is zero, then animation will "freeze".

		if (_paused)
			return;

		if (_currAnim == null)
			return;

		_frameElapsed += dt * _speed;

		// If frame elapsed more than frame rate, update
		// frame to next index. The use of "while" ensures
		// that frames paused for too long fast-forwarded.
		while (_frameElapsed > _frameRate)
		{
			if (_reverse)
			{
				_frameIndex--;

				if (_frameIndex < 0)
				{
					if (_currAnim._loop)
						_frameIndex = _currAnim._frames.length-1;
					else
						_frameIndex = 0;
				}
					
			}
			else
			{
				_frameIndex++;

				if (_frameIndex >= _currAnim._frames.length)
				{
					if (_currAnim._loop)
						_frameIndex = 0;
					else
						_frameIndex = _currAnim._frames.length-1;
				}
			}

			_frameElapsed -= _frameRate;
		}
	}

	public function destroy ()
	{
		_animations = null;
		_currAnim = null;
	}

	/**
	* Adds a new animation data. Animator doesn't know anything about
	* the spritesheet, it just stores array data of the frame indices
	* it should play when its name is called.
	*
	* NOTE:
	* frames store the index for the animation
	* e.g. frames = [0,3,5,4]
	* this means the animation plays frames 0-3-5-4 in order.
	*/
	public function add (name:String, frames:Array<Int>, fps:Int=30, loop:Bool=true):Void
	{
		var anim:WyAnimation = new WyAnimation(this, name, frames, fps, loop);
		_animations[name] = anim;

		if (_currAnim == null)
			_currAnim = anim;
	}

	public function play (name:String, reset:Bool=false)
	{
		// NOTE:
		// - for now, playing a new animation will always reset

		if (_currAnim == null)
			return;

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

	public function getSheetIndex ():Int
	{
		// Returns the current animation's frame index in the sprite sheet
		return (_currAnim != null) ? _currAnim.getFrameIndex(_frameIndex) : 0;
	}
}