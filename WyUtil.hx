package wy;

class WyUtil
{
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
	public inline static function clamp(value:Float, min:Float, max:Float):Float
	{
	    if (value < min)
	        return min;
	    else if (value > max)
	        return max;
	    else
	        return value;
	}
}