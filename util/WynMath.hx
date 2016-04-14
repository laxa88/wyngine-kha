package wyn.util;

import kha.math.FastMatrix3;

class WynMath
{
	/**
	 * "Clamps" a value to boundaries [min, max].
	 * Example:
	 * clamp(2, 1, 5) == 2;
	 * clamp(0, 1, 5) == 1;
	 * clamp(6, 1, 5) == 5;
	 */
	public inline static function clamp (value:Float, min:Float, max:Float):Float
	{
		if (value < min)
			return min;
		else if (value > max)
			return max;
		else
			return value;
	}

	/**
	 * Clamps from 0 to 1
	 */
	public inline static function clamp01 (value:Float) : Float
	{
		if (value < 0)
			value = 0;
		if (value > 1)
			value = 1;
		return value;
	}

	/**
	 * Original code is taken, thanks to Andrey Sitnik, from:
	 * - http://easings.net/
	 * - https://github.com/ai/easings.net/blob/master/vendor/jquery.easing.js
	 * t: current time
	 * b: beginning value (e.g. x=100)
	 * c: changed value (e.g. x=150)
	 * d: duration
	 *
	 * The functions below are refactored version of Sitnik's code,
	 * thanks to David King, from:
	 * - http://oodavid.com/2013/11/11/easing-functions-refactored.html
	 * - https://github.com/oodavid/timestep/blob/master/src/animate/transitions.js
	 * n: t/d (assuming b=0, c=1)
	 * returns: Float (0 to 1)
	 *
	 * The refactored version also contains bugfix on the ease-elastic function.
	 */

	public static function linear (n:Float) : Float
	{
		return n;
	}
	public static function easeInQuad (n:Float) : Float
	{
		return easeIn(n);
	}
	public static function easeIn (n:Float) : Float
	{
		return n * n;
	}
	public static function easeOutQuad (n:Float) : Float
	{
		return easeOut(n);
	}
	public static function easeOut (n:Float) : Float
	{
		return n * (2 - n);
	}
	public static function easeInOutQuad (n:Float) : Float
	{
		if ((n *= 2) < 1) return 0.5 * n * n;
		return -0.5 * ((--n) * (n - 2) - 1);
	}
	public static function easeInCubic (n:Float) : Float
	{
		return n * n * n;
	}
	public static function easeOutCubic (n:Float) : Float
	{
		return ((n -= 1) * n * n + 1);
	}
	public static function easeInOutCubic (n:Float) : Float
	{
		return easeInOut(n);
	}
	public static function easeInOut (n:Float) : Float
	{
		if ((n *= 2) < 1) return 0.5 * n * n * n;
		return 0.5 * ((n -= 2) * n * n + 2);
	}
	public static function easeInQuart (n:Float) : Float
	{
		return n * n * n * n;
	}
	public static function easeOutQuart (n:Float) : Float
	{
		return -1 * ((n -= 1) * n * n * n - 1);
	}
	public static function easeInOutQuart (n:Float) : Float
	{
		if ((n *= 2) < 1) return 0.5 * n * n * n * n;
		return -0.5 * ((n -= 2) * n * n * n - 2);
	}
	public static function easeInQuint (n:Float) : Float
	{
		return n * n * n * n * n;
	}
	public static function easeOutQuint (n:Float) : Float
	{
		return ((n -= 1) * n * n * n * n + 1);
	}
	public static function easeInOutQuint (n:Float) : Float
	{
		if ((n *= 2) < 1) return 0.5 * n * n * n * n * n;
		return 0.5 * ((n -= 2) * n * n * n * n + 2);
	}
	public static function easeInSine (n:Float) : Float
	{
		if (n == 0) return 0;
		if (n == 1) return 1;
		return -1 * Math.cos(n * (Math.PI / 2)) + 1;
	}
	public static function easeOutSine (n:Float) : Float
	{
		if (n == 0) return 0;
		if (n == 1) return 1;
		return Math.sin(n * (Math.PI / 2));
	}
	public static function easeInOutSine (n:Float) : Float
	{
		if (n == 0) return 0;
		if (n == 1) return 1;
		return -0.5 * (Math.cos(Math.PI * n) - 1);
	}
	public static function easeInExpo (n:Float) : Float
	{
		if (n == 0) return 0;
		if (n == 1) return 1;
		return (n == 0) ? 0 : Math.pow(2, 10 * (n - 1));
	}
	public static function easeOutExpo (n:Float) : Float
	{
		if (n == 0) return 0;
		if (n == 1) return 1;
		return (n == 1) ? 1 : (-Math.pow(2, -10 * n) + 1);
	}
	public static function easeInOutExpo (n:Float) : Float
	{
		if (n == 0) return 0;
		if (n == 1) return 1;
		if ((n *= 2) < 1) return 0.5 * Math.pow(2, 10 * (n - 1));
		return 0.5 * (-Math.pow(2, -10 * --n) + 2);
	}
	public static function easeInCirc (n:Float) : Float
	{
		if (n == 0) return 0;
		if (n == 1) return 1;
		return -1 * (Math.sqrt(1 - n * n) - 1);
	}
	public static function easeOutCirc (n:Float) : Float
	{
		if (n == 0) return 0;
		if (n == 1) return 1;
		return  Math.sqrt(1 - (n -= 1) * n);
	}
	public static function easeInOutCirc (n:Float) : Float
	{
		if (n == 0) return 0;
		if (n == 1) return 1;
		if ((n*=2) < 1) return -0.5 * (Math.sqrt(1 - n * n) - 1);
		return 0.5 * (Math.sqrt(1 - (n -= 2) * n) + 1);
	}
	public static function easeInElastic (n:Float) : Float
	{
		if (n == 0) return 0;
		if (n == 1) return 1;
		var p = 0.3;
		var s = 0.075;	// p / (2 * Math.PI) * Math.asin(1)
		return -(Math.pow(2, 10 * (n -= 1)) * Math.sin((n - s) * (2 * Math.PI) / p));
	}
	public static function easeOutElastic (n:Float) : Float
	{
		if (n == 0) return 0;
		if (n == 1) return 1;
		var p = 0.3;
		var s = 0.075;	// p / (2 * Math.PI) * Math.asin(1)
		return Math.pow(2,-10 * n) * Math.sin((n - s) * (2 * Math.PI) / p) + 1;
	}
	public static function easeInOutElastic (n:Float) : Float
	{
		if (n == 0) return 0;
		if ((n *= 2) == 2) return 1;
		var p = 0.45;	// 0.3 * 1.5
		var s = 0.1125;	// p / (2 * Math.PI) * Math.asin(1)
		if (n < 1) return -.5 * (Math.pow(2, 10 * (n -= 1)) * Math.sin((n * 1 - s) * (2 * Math.PI) / p));
		return Math.pow(2, -10 * (n -= 1)) * Math.sin((n * 1 - s) * (2 * Math.PI) / p ) * .5 + 1;
	}
	public static function easeInBack (n:Float) : Float
	{
		if (n == 0) return 0;
		if (n == 1) return 1;
		var s = 1.70158;
		return n * n * ((s + 1) * n - s);
	}
	public static function easeOutBack (n:Float) : Float
	{
		if (n == 0) return 0;
		if (n == 1) return 1;
		var s = 1.70158;
		return ((n -= 1) * n * ((s + 1) * n + s) + 1);
	}
	public static function easeInOutBack (n:Float) : Float
	{
		if (n == 0) return 0;
		if (n == 1) return 1;
		var s = 1.70158;
		if ((n *= 2) < 1) return 0.5 * (n * n * (((s *= 1.525) + 1) * n - s));
		return 0.5 * ((n -= 2) * n * (((s *= 1.525) + 1) * n + s) + 2);
	}
	public static function easeOutBounce (n:Float) : Float
	{
		if (n == 0) return 0;
		if (n == 1) return 1;
		if (n < (1 / 2.75)) {
			return (7.5625 * n * n);
		} else if (n < (2 / 2.75)) {
			return (7.5625 * (n -= (1.5 / 2.75)) * n + .75);
		} else if (n < (2.5 / 2.75)) {
			return (7.5625 * (n -= (2.25 / 2.75)) * n + .9375);
		} else {
			return (7.5625 * (n -= (2.625 / 2.75)) * n + .984375);
		}
	}
	public static function easeInBounce (n:Float) : Float
	{
		return 1 - easeOutBounce(1 - n);
	}
	public static function easeInOutBounce (n:Float) : Float
	{
		if (n < 0.5) return easeInBounce(n * 2) * .5;
		return easeOutBounce((n * 2) - 1) * .5 + .5;
	}
	public static function lerp (n:Float) : Float
	{
		// lerp is aka linear!
		return linear(n);
	}
	public static function smoothstep (n:Float) : Float
	{
		// https://en.wikipedia.org/wiki/Smoothstep
		return n*n*(3-2*n);
	}
	public static function smootherstep (n:Float) : Float
	{
		// https://en.wikipedia.org/wiki/Smoothstep
		return n*n*n*(n*(n*6-15)+10);
	}
}