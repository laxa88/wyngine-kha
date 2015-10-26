package wyn;

import kha.math.FastVector2;

class WynUtil
{
	/**
	 * Applies accel/drag/maxVelocity to velocity, then returns the new velocity.
	 * 		- If there's velocity, don't use drag.
	 * 		- Else, if there's drag, compute velocity toward zero.
	 * 		- Finally, clamp the max velocity if given.
	 */
	public static function computeVelocity (dt:Float, vel:Float, accel:Float, drag:Float, max:Float = 0) : Float
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

		if ((vel != 0) && (max != 0))
		{
			if (vel > max)
				vel = max;
			else if (vel < -max)
				vel = -max;
		}

		return vel;
	}

	/**
	 * Converts specified angle in radians to degrees.
	 * @return angle in degrees (not normalized to 0...360)
	 */
	public inline static function radToDeg(rad:Float):Float
	{
	    return 180 / Math.PI * rad;
	}

	/**
	 * Converts specified angle in degrees to radians.
	 * @return angle in radians (not normalized to 0...Math.PI*2)
	 */
	public inline static function degToRad(deg:Float):Float
	{
	    return Math.PI / 180 * deg;
	}

	/**
	 * "Clamps" a value to boundaries [min, max].
	 * Example:
	 * clamp(2, 1, 5) == 2;
	 * clamp(0, 1, 5) == 1;
	 * clamp(6, 1, 5) == 5;
	 */
	public static function clamp(value:Float, min:Float, max:Float):Float
	{
	    if (value < min)
	        return min;
	    else if (value > max)
	        return max;
	    else
	        return value;
	}

	/**
	 * NOTE: make sure Random is init() with a seed before calling this!
	 * Returns a normalised x/y value within a circle
	 */
	public inline static function randomInCircle () : FastVector2
	{
		var x = Math.random() * ((Math.random() > 0.5) ? -1 : 1);
		var y = Math.random() * ((Math.random() > 0.5) ? -1 : 1);
		var p:FastVector2 = new FastVector2(x, y);
		return p;
	}

	/**
	 * NOTE: make sure Random is init() with a seed before calling this!
	 * Returns a normalised x/y value, normalised to circumference of a circle
	 */
	public inline static function randomOnCircle () : FastVector2
	{
		var p:FastVector2 = randomInCircle();
		p.normalize();
		return p;
	}

	/**
	 * Remember:
	 * - zero angles is to the EAST (x=1,y=0)
	 * - negative-y is actually UP on the screen
	 */
	public inline static function radToVector (rad:Float) : FastVector2
	{
		return new FastVector2(Math.cos(rad), Math.sin(rad));
	}

	public inline static function degToVector (angle:Float) : FastVector2
	{
		return radToVector(degToRad(angle));
	}

	// public inline static function vectorToRad (v:FastVector2) : Float
	// {
	// 	// does this affect v directly?
	// }

	// public inline static function vectorToDeg (v:FastVector2) : Float
	// {

	// }
}