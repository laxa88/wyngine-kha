package wyn;

class WynParticle extends WynSprite
{
	// TODO
	// - animate particle color (perhaps too fancy, skip for now)
	// - friction (for particles that interact with surroundings)

	public var lifespan:Float = 0;
	// public var friction:Float = 0; // used for collision against walls
	public var useFading:Bool = false;
	public var useScaling:Bool = false;
	// public var useColoring:Bool = false;
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

	public function new (isStaticPosition:Bool=true)
	{
		super();

		// By default, particle positions are not affected by emitter's position.
		this.isStaticPosition = isStaticPosition;
	}

	override public function update (dt:Float)
	{
		super.update(dt);

		// Only animate scale/alpha and flag to kill if lifespan is not zero.
		if (lifespan > 0)
		{
			lifeElapsed += dt;

			updateParticle();

			if (lifeElapsed >= lifespan)
			{
				// set final alpha and scale before killing
				alpha = endAlpha;
				scale = endScale;

				kill();
			}
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