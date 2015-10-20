package wy;

class WyUtil
{
	/**
		Velocity requires some checks, so leave this as a general utility.
		- If there's velocity, don't use drag.
		- Else, if there's drag, move velocity toward zero.
		- Also, clamp the max velocity if given.
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
}