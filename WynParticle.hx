package wyn;

class WynParticle extends WynSprite
{
	public var lifespan:Float = 0;
	// public var friction:Float = 0; // used for collision against walls
	public var useFading:Bool = false;
	public var useScaling:Bool = false;
	// public var useColoring:Bool = false;
	// public var maxLifespan:Float = 0;
	public var startAlpha:Float = 0;
	public var endAlpha:Float = 0;
	public var startScale:Float = 0;
	public var endScale:Float = 0;
	// public var startRed:Float = 0;
	// public var startGreen:Float = 0;
	// public var startBlue:Float = 0;
	// public var endRed:Float = 0;
	// public var endGreen:Float = 0;
	// public var endBlue:Float = 0;
	var lifeElapsed:Float = 0;

	override public function update (dt:Float)
	{
		super.update(dt);

		// Only flag to kill if lifespan is not zero (infinite)
		if (lifespan > 0)
		{
			lifeElapsed += dt;

			updateParticle();

			if (lifeElapsed >= lifespan)
				kill();
		}
	}

	function updateParticle ()
	{
		if (useFading)
			alpha = startAlpha + (lifeElapsed / lifespan) * (endAlpha - startAlpha);

		if (useScaling)
			scale = startScale + (lifeElapsed / lifespan) * (endScale - startScale);
	}

	public function reset ()
	{
		lifeElapsed = 0;

		// Update the particle once before it even starts to emit
		updateParticle();
	}
}