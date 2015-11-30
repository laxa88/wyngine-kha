package wyn;

import kha.math.FastVector2;

class WynObject
{
	/**
	 * This is the base of all Wyn objects, like FlxBasic.
	 */

	private static var ID_COUNTER:Int = 0;
	public static inline var NONE:Int = 0;
	public static inline var OBJECT:Int = 1;
	public static inline var GROUP:Int = 2;
	public static inline var TILE:Int = 3;

	public static inline var HITBOX:Int = 1;
	public static inline var HITCIRCLE:Int = 2;

	public var id:Int = -1; // unique identifier for objects. Currently unused internally.
	public var name:String = ""; // non-unique identifier for your custom usage.
	public var exists:Bool = true;
	public var alive:Bool = true;
	public var active:Bool = true;
	public var visible:Bool = true;
	public var objectType(default, null):Int = WynObject.NONE;

	public var parent:WynObject; // used with WynGroup to identify this object's parent
	public var isStaticPosition:Bool = false; // set true if position is independent of parent position
	public var localx(get, set):Float; // relative to parent
	public var localy(get, set):Float;
	public var x(default, set):Float = 0; // Note: position origin is at top-left corner.
	public var y(default, set):Float = 0;
	public var scrollFactorX:Float = 1; // For parallax or GUI use
	public var scrollFactorY:Float = 1;
	public var width(default, set):Float = 0; // By default, hitbox size is same as image size
	public var height(default, set):Float = 0;
	public var radius(default, set):Float = 0;
	public var hitboxType:Int = HITBOX;
	public var offset:FastVector2 = new FastVector2(); // hitbox offset

	// This stores the previous x/y values for convenience. When doing collision
	// with something, we may not want to draw the object at the latest position,
	// or adjust the position to the collision point.
	var oldX:Float = 0;
	var oldY:Float = 0;

	public var angle:Float = 0; // Note: Rotations are costly, especially on flash!
	public var velocity(default, null):FastVector2 = new FastVector2();
	public var acceleration(default, null):FastVector2 = new FastVector2();
	public var drag(default, null):FastVector2 = new FastVector2();
	public var maxVelocity(default, null):FastVector2 = new FastVector2();
	public var angularVelocity:Float = 0;
	public var angularAcceleration:Float = 0; // acceleration for angle
	public var angularDrag:Float = 0;
	public var angularMaxVelocity:Float = 0;

	// TODO - tiled variable
	// public var immovable:Bool; // for tile or non-movable physic objects
	// public var solid:Bool; // 



	public function new (x:Float=0, y:Float=0, w:Float=0, h:Float=0)
	{
		this.x = x;
		this.y = y;
		this.width = w;
		this.height = h;

		id = ID_COUNTER++;
		objectType = WynObject.OBJECT;
	}

	public function update (dt:Float)
	{
		// Update physics
		velocity.x = WynUtil.computeVelocity(dt, velocity.x, acceleration.x, drag.x, maxVelocity.x);
		velocity.y = WynUtil.computeVelocity(dt, velocity.y, acceleration.y, drag.y, maxVelocity.y);
		oldX = x;
		oldY = y;
		x += dt * velocity.x;
		y += dt * velocity.y;

		// Update rotation
		angularVelocity = WynUtil.computeVelocity(dt, angularVelocity, angularAcceleration, angularDrag, angularMaxVelocity);
		angle += dt * angularVelocity;
	}

	public function render (c:WynCamera)
	{
		// By default, empty objects don't have image.
		// Do rendering logic in WynSprite instead.
	}

	public function destroy ()
	{
		// In case we have variables that need to be manually cleaned
		// for garbage collection, do it here.

		velocity = null;
		acceleration = null;
		drag = null;
		maxVelocity = null;

		exists = false;
	}

	/**
	 * This flags the object for pooling.
	 */
	public function kill ()
	{
		alive = false;
		exists = false;
	}

	/**
	 * This flags the object for pooling.
	 */
	public function revive ()
	{
		alive = true;
		exists = true;
	}

	/**
	 * When you don't need fancy quadtrees, you can
	 * use this for single checks.
	 */
	public function collide (other:WynObject) : Bool
	{
		velocity.x = WynUtil.computeVelocity(dt, velocity.x, acceleration.x, drag.x, maxVelocity.x);
		velocity.y = WynUtil.computeVelocity(dt, velocity.y, acceleration.y, drag.y, maxVelocity.y);
		x += dt * velocity.x;
		y += dt * velocity.y;

		if (hitboxType == HITBOX)
		{
			if (other.hitboxType == HITBOX)
			{
				return collideRectWithRect(other);
			}
			else if (other.hitboxType == HITCIRCLE)
			{
				return collideRectWithCircle(other);
			}
		}
		else if (hitboxType == HITCIRCLE)
		{
			if (other.hitboxType == HITBOX)
			{
				return other.collideRectWithCircle(this);
			}
			else if (other.hitboxType == HITCIRCLE)
			{
				return collideCircleWithCircle(other);
			}
		}

		return false;
	}

	function collideRectWithRect (other:WynObject) : Bool
	{
		var hitHoriz:Bool = false;
		var hitVert:Bool = false;
		var thisX:Float = x + offset.x;
		var thisY:Float = y + offset.y;
		var otherX:Float = other.x + other.offset.x;
		var otherY:Float = other.y + other.offset.y;

		if (thisX < otherX)
			hitHoriz = otherX < (thisX + width);
		else
			hitHoriz = thisX < (otherX + other.width);

		if (thisY < otherY)
			hitVert = otherY < (thisY + height);
		else
			hitVert = thisY < (otherY + other.height);

		return (hitHoriz && hitVert);
	}

	function collideRectWithCircle (other:WynObject) : Bool
	{
		// Based on code from HaxePunk's Circle.hx
		// https://github.com/HaxePunk/HaxePunk/blob/306f7cc50356a698859434641613b7c95bfbba4f/com/haxepunk/masks/Circle.hx

		var _otherHalfWidth:Float = width * 0.5;
		var _otherHalfHeight:Float = height * 0.5;
		var _squaredRadius = other.radius * other.radius;

		var px:Float = other.x + other.offset.x,
			py:Float = other.y + other.offset.y;

		var ox:Float = x + offset.x,
			oy:Float = y + offset.y;

		var distanceX:Float = Math.abs(px - ox - _otherHalfWidth),
			distanceY:Float = Math.abs(py - oy - _otherHalfHeight);

		if (distanceX > _otherHalfWidth + radius || distanceY > _otherHalfHeight + radius)
		{
			return false;	// the hitbox is too far away so return false
		}
		if (distanceX <= _otherHalfWidth || distanceY <= _otherHalfHeight)
		{
			return true;
		}
		var distanceToCorner:Float = (distanceX - _otherHalfWidth) * (distanceX - _otherHalfWidth)
			+ (distanceY - _otherHalfHeight) * (distanceY - _otherHalfHeight);

		return distanceToCorner <= _squaredRadius;
	}

	function collideCircleWithCircle (other:WynObject) : Bool
	{
		// Based on code from HaxePunk's Circle.hx
		// https://github.com/HaxePunk/HaxePunk/blob/306f7cc50356a698859434641613b7c95bfbba4f/com/haxepunk/masks/Circle.hx

		// TODO - check if we need to include offsets
		var dx:Float = x - other.x;
		var dy:Float = y - other.y;

		return (dx * dx + dy * dy) < Math.pow(radius + other.radius, 2);
	}

	public function setHitbox (offsetX:Float, offsetY:Float, w:Float, h:Float)
	{
		hitboxType = WynObject.HITBOX;
		offset.x = offsetX;
		offset.y = offsetY;
		width = w;
		height = h;
		// radius = 0;
	}

	public function setHitcircle (offsetX:Float, offsetY:Float, r:Float)
	{
		hitboxType = WynObject.HITCIRCLE;
		offset.x = offsetX;
		offset.y = offsetY;
		// width = 0;
		// height = 0;
		radius = r;
	}

	public function setCenterPosition (x:Float, y:Float)
	{
		this.x = x - width/2 - offset.x;
		this.y = y - height/2 - offset.y;
	}

	public function getCenterPosition () : FastVector2
	{
		return new FastVector2(x + width/2 + offset.x, y + height/2 + offset.y);
	}

	/**
	 * Useful for resetting position quickly in one line
	 */
	public function setPosition (x:Float, y:Float)
	{
		this.x = x;
		this.y = y;
	}

	/**
	 * Sets how affected this object's x/y position is affected by the camera's scroll.
	 * E.g. if camera scroll = [50,50], object position = [80, 80],
	 * Thus the object's visible position = [30, 30]
	 * However, if scrollFactor is [0.5, 0.5], then the object's visible
	 * position becomes [55, 55].
	 *
	 * For common use:
	 * - set scrollFactor to [0,0] for UI elements
	 * - set scrollFactor for backgrounds images to values < 1 for parallax effect
	 */
	public function setScrollFactor (x:Float, y:Float)
	{
		scrollFactorX = x;
		scrollFactorY = y;
	}

	private function set_x (val:Float) : Float
	{
		return x = val;
	}

	private function set_y (val:Float) : Float
	{
		return y = val;
	}

	private function set_width (val:Float) : Float
	{
		width = val;
		if (width < 0) width = 0;
		return width;
	}

	private function set_height (val:Float) : Float
	{
		height = val;
		if (height < 0) height = 0;
		return height;
	}

	private function set_radius (val:Float) : Float
	{
		return (radius = val);
	}

	private function get_localx () : Float
	{
		if (parent != null)
			return x - parent.x;
		else
			return 0;
	}

	private function get_localy () : Float
	{
		if (parent != null)
			return y - parent.y;
		else
			return 0;
	}

	private function set_localx (val:Float) : Float
	{
		if (parent != null)
			return x = parent.x + (val * scrollFactorX);
		else
			return 0;
	}

	private function set_localy (val:Float) : Float
	{
		if (parent != null)
			return y = parent.y + (val * scrollFactorY);
		else
			return 0;
	}
}