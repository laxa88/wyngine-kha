package wyn;

import kha.math.FastVector2;
import kha.graphics2.Graphics;

class WynObject
{
	/**
	 * This is the base of all Wyn objects, like FlxBasic.
	 */

	private static var ID_COUNTER:Int = 0;

	public var id:Int = -1;
	public var exists:Bool = true;
	public var alive:Bool = true;
	public var active:Bool = true;
	public var visible:Bool = true;
	public var objectType(default, null):WynObjectType = WynObjectType.NONE;

	public var x:Float = 0; // Note: position origin is at top-left corner.
	public var y:Float = 0;
	public var width:Float = 0; // By default, hitbox size is same as image size
	public var height:Float = 0;
	//public var center(get,set):{x:}

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
		objectType = WynObjectType.OBJECT;

		Wyngine.log("new : " + id);
	}

	public function update (dt:Float)
	{
		// Update physics
		velocity.x = WynUtil.computeVelocity(dt, velocity.x, acceleration.x, drag.x, maxVelocity.x);
		velocity.y = WynUtil.computeVelocity(dt, velocity.y, acceleration.y, drag.y, maxVelocity.y);
		x += dt * velocity.x;
		y += dt * velocity.y;

		// Update rotation
		angularVelocity = WynUtil.computeVelocity(dt, angularVelocity, angularAcceleration, angularDrag, angularMaxVelocity);
		angle += dt * angularVelocity;
	}

	public function render (g:Graphics)
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
		var hitHoriz:Bool;
		var hitVert:Bool;

		if (x < other.x)
			hitHoriz = other.x < (x + width);
		else
			hitHoriz = x < (other.x + other.width);

		if (y < other.y)
			hitVert = other.y < (y + height);
		else
			hitVert = y < (other.y + other.height);

		return (hitHoriz && hitVert);
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
	 * Useful for resetting position quickly in one line.
	 * Instead of top-left, this offsets to the center of the object.
	 */
	public function setCenterPosition (x:Float, y:Float)
	{
		this.x = x - width/2;
		this.y = y - height/2;
	}

	public function getCenterPosition () : FastVector2
	{
		return new FastVector2(x+width/2, y+height/2);
	}
}