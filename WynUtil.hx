package wyn;

import kha.math.FastVector2;
import kha.math.Random;

class WynUtil
{
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

	/**
	 * Converts specified angle in radians to degrees.
	 * @return angle in degrees (not normalized to 0...360)
	 */
	inline public static function radToDeg (rad:Float) : Float
	{
	    return 180 / Math.PI * rad;
	}

	/**
	 * Converts specified angle in degrees to radians.
	 * @return angle in radians (not normalized to 0...Math.PI*2)
	 */
	inline public static function degToRad (deg:Float) : Float
	{
	    return Math.PI / 180 * deg;
	}

	/**
	 * NOTE: make sure Random is init() with a seed before calling this!
	 * Returns a normalised x/y value within a circle
	 */
	inline public static function randomInCircle () : FastVector2
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
	inline public static function randomOnCircle () : FastVector2
	{
		var p:FastVector2 = randomInCircle();
		p.normalize();
		return p;
	}

	/**
	 * Kha only has Int version, so get a float one
	 * Note: min and max are inclusive.
	 */
	inline public static function randomFloat (min:Float, max:Float) : Float
	{
		if (min == max)
		{
			return min;
		}
		else
		{
			var r = 0.0;
			if (min > max)
			{
				// If min is larger than max, revert the calculation
				r = Math.random() * (min - max);
				return (max + r);
			}
			else
			{
				r = Math.random() * (max - min);
				return (min + r);
			}
		}
	}

	/**
	 * Great for getting random array index.
	 * Note: min and max are inclusive.
	 */
	inline public static function randomInt (min:Int, max:Int) : Int
	{
		if (min == max)
		{
			return min;
		}
		else
		{
			var r = 0;
			if (min > max)
			{
				// If min is larger than max, revert the calculation
				r = Math.round(Math.random() * (min - max));
				return (max + r);
			}
			else
			{
				r = Math.round(Math.random() * (max - min));
				return (min + r);
			}
		}
	}

	/**
	 * Remember:
	 * - angle 0 = EAST (x=1,y=0)
	 * - angle 90 = SOUTH
	 * - angle 180 = WEST
	 * - angle -90 = NORTH
	 * - negative-y is actually UP on the screen
	 */
	inline public static function radToVector (rad:Float) : FastVector2
	{
		return new FastVector2(Math.cos(rad), Math.sin(rad));
	}

	inline public static function degToVector (angle:Float) : FastVector2
	{
		return radToVector(degToRad(angle));
	}

	inline // public static function vectorToRad (v:FastVector2) : Float
	// {
	// 	// does this affect v directly?
	// }

	inline // public static function vectorToDeg (v:FastVector2) : Float
	// {

	// }

	inline public static function roundToPrecision (v:Float, precision:Int) : Float
	{
		return Math.round( v * Math.pow(10, precision) ) / Math.pow(10, precision);
	}

	inline public static function roundToPrecisionString (v:Float, precision:Int) : String
	{
		var n = Math.round(v * Math.pow(10, precision));
		var str = '' + n;
		var len = str.length;

		if (len <= precision)
		{
			// Example: v = 0.01234
			// n = 1
			// str = "1"
			// len = 1
			// str = "01"
			// return "0.01";

			while (len < precision)
			{
				str = '0' + str;
				len++;
			}

			return '0.' + str;
		}
		else
		{
			// Example: v = 5.1234
			// n = 512
			// str = "512"
			// len = 3
			// return "5" + "." + "12"

			return str.substr(0, str.length-precision) + '.' + str.substr(str.length-precision);
		}
	}
}