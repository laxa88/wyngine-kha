package wyn.util;

import kha.Image;
import kha.Color;
import kha.math.FastVector2;
import kha.math.Random;

class WynUtil
{
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

	inline public static function roundToPrecisionString (v:Float, precision:Int, separator:String='.') : String
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

			return '0' + separator + str;
		}
		else
		{
			// Example: v = 5.1234
			// n = 512
			// str = "512"
			// len = 3
			// return "5" + "." + "12"

			return str.substr(0, str.length-precision) + separator + str.substr(str.length-precision);
		}
	}

	inline public static function createRectImage (w:Int, h:Int, c:Color) : Image
	{
		var img:Image = Image.createRenderTarget(w, h);
		img.g2.begin(true, 0x00000000);
		img.g2.color = c;
		img.g2.drawRect(0, 0, w, h);
		img.g2.end();
		return img;
	}

	inline public static function createRectImageFilled (w:Int, h:Int, c:Color) : Image
	{
		var img:Image = Image.createRenderTarget(w, h);
		img.g2.begin(true, 0x00000000);
		img.g2.color = c;
		img.g2.fillRect(0, 0, w, h);
		img.g2.end();
		return img;
	}
}