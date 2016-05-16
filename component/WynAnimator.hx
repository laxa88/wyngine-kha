package wyn.component;

import kha.Image;
import wyn.Wyngine;

class WynAnimator extends WynComponent
{
	// NOTES:
	// - REQUIRES WynSprite
	// - Does not know what atlas WynSprite has.
	// - Only blindly updates the animation variables and assigns the region to the WynSprite.

	public var sprite:WynSprite;

	public var speed:Float = 1; // positive = forward, negative = backwards
	var playing:Bool = false;
	var animations:Map<String, AnimData>;

	var fps:Float = 1; // frames per second
	var currAnimationArr:Array<Region> = [];
	var currAnimationName:String = "";
	var currAnimationMaxIndex:Int = 0;
	var currIndex:Int = 0;
	var loop:Bool = false;
	var elapsed:Float = 0;
	var onComplete:Void->Void;



	public function new (tSprite:WynSprite)
	{
		super();

		sprite = tSprite;
		animations = new Map<String, AnimData>();
	}

	override public function update ()
	{
		super.update();

		if (!enabled || !active)
			return;

		if (playing)
		{
			elapsed += Wyngine.dt * Math.abs(speed);

			// next frame
			if (elapsed >= 1/fps)
			{
				elapsed -= (1/fps);

				currIndex += (speed >= 0) ? 1 : -1;

				var ended:Bool = false;
				if (currIndex >= currAnimationMaxIndex)
				{
					if (loop)
						currIndex = 0;
					else
						currIndex = currAnimationMaxIndex-1;

					ended = true;
				}
				else if (currIndex < 0)
				{
					if (loop)
						currIndex = currAnimationMaxIndex-1;
					else
						currIndex = 0;

					ended = true;
				}

				if (ended)
				{
					if (!loop)
						playing = false;

					if (onComplete != null)
						onComplete();
				}
			}

			// update region
			if (sprite != null)
				sprite.region = currAnimationArr[currIndex];
		}
	}

	override public function destroy ()
	{
		super.destroy();

		sprite = null;
		animations = null;
		currAnimationArr = [];
		onComplete = null;
	}



	public function addAnimation (name:String, regions:Array<Region>, fps:Int=12)
	{
		if (animations.exists(name))
			trace('animation $name already exists, overwriting...');

		animations.set(name, {
			name: name,
			regions: regions,
			fps: fps
		});
	}

	public function removeAnimation (name:String)
	{
		animations.remove(name);
	}

	public function playAnimation (name:String, loop:Bool=true, restart:Bool=true, onComplete:Void->Void=null)
	{
		if (!animations.exists(name))
		{
			trace('animation $name does not exist');
			return;
		}

		var animData:AnimData = animations.get(name);

		fps = animData.fps;
		currAnimationArr = animData.regions;
		currAnimationName = animData.name;
		currAnimationMaxIndex = currAnimationArr.length;
		if (restart)
		{
			currIndex = 0;
			elapsed = 0;

			// immediately update the sprite
			if (sprite != null)
				sprite.region = currAnimationArr[currIndex];
		}
		this.loop = loop;
		this.onComplete = onComplete;

		playing = true;
	}

	public function pauseAnimation ()
	{
		playing = false;
	}

	public function stopAnimation ()
	{
		playing = false;
		currIndex = 0;
		elapsed = 0;
	}
}