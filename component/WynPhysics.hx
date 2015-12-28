package wyn.component;

class WynPhysics extends WynComponent
{
	var oldX:Float = 0;
	var oldY:Float = 0;
	public var velocityX:Float = 0; // current movespeed
	public var velocityY:Float = 0;
	public var accelerationX:Float = 0; // for gravity
	public var accelerationY:Float = 0;
	public var dragX:Float = 0; // for slowing down velocity
	public var dragY:Float = 0;
	public var maxVelocityX:Float = 0;
	public var maxVelocityY:Float = 0;
	public var angularVelocity:Float = 0;
	public var angularAcceleration:Float = 0; // acceleration for angle
	public var angularDrag:Float = 0;
	public var angularMaxVelocity:Float = 0;

	override public function update ()
	{
		if (!active)
			return;

		// Update physics
		velocityX = computeVelocity(Wyngine.dt, velocityX, accelerationX, dragX, maxVelocityX);
		velocityY = computeVelocity(Wyngine.dt, velocityY, accelerationY, dragY, maxVelocityY);
		oldX = parent.x;
		oldY = parent.y;
		parent.x += Wyngine.dt * velocityX;
		parent.y += Wyngine.dt * velocityY;

		// Update rotation
		angularVelocity = computeVelocity(Wyngine.dt, angularVelocity, angularAcceleration, angularDrag, angularMaxVelocity);
		parent.angle += Wyngine.dt * angularVelocity;
	}



	/**
	 * Applies accel/drag/maxVelocity to velocity, then returns the new velocity.
	 * 		- If there's accel, don't use drag.
	 * 		- Else, if there's drag, compute velocity toward zero.
	 * 		- Finally, clamp the max velocity if given.
	 * Returns the new velocity.
	 */
	inline public static function computeVelocity (dt:Float, vel:Float, accel:Float, drag:Float, max:Float = 0) : Float
	{
		// Taken from FlxVelocity
		if (accel != 0)
			vel += accel * dt;
		else if (drag != 0)
		{
			var d:Float = drag * dt;
			if (vel - d > 0)
				vel = vel - d;
			else if (vel + d < 0)
				vel += d;
			else
				vel = 0;
		}

		// Only cap velocity if max is not zero.
		if ((vel != 0) && (max != 0))
		{
			if (vel > max)
				vel = max;
			else if (vel < -max)
				vel = -max;
		}

		return vel;
	}

	inline public function setVelocity (x:Float, y:Float)
	{
		velocityX = x;
		velocityY = y;
	}

	inline public function setAcceleration (x:Float, y:Float)
	{
		accelerationX = x;
		accelerationY = y;
	}

	inline public function setDrag (x:Float, y:Float)
	{
		dragX = x;
		dragY = y;
	}

	inline public function setMaxVelocity (x:Float, y:Float)
	{
		maxVelocityX = x;
		maxVelocityY = y;
	}
}