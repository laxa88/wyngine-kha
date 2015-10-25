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
	public var exists:Bool;
	public var alive:Bool;
	public var active:Bool;
	public var visible:Bool;
	public var objectType(default, null):WynObjectType;

	public var x:Float = 0; // Note: position origin is at top-left corner.
	public var y:Float = 0;
	public var width:Float = 0; // By default, hitbox size is same as image size
	public var height:Float = 0;

	public var angle:Float = 0; // Note: Rotations are costly, especially on flash!
	public var velocity(default, null):FastVector2;
	public var acceleration(default, null):FastVector2;
	public var drag(default, null):FastVector2;
	public var maxVelocity(default, null):FastVector2;
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

		velocity = new FastVector2();
		acceleration = new FastVector2();
		drag = new FastVector2();
		maxVelocity = new FastVector2();

		objectType = WynObjectType.OBJECT;

		init();
	}

	public function init ()
	{
		// To be overridden by derived classes
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
	}

	public function destroy ()
	{
		// In case we have variables that need to be manually cleaned
		// for garbage collection, do it here.

		velocity = null;
		acceleration = null;
		drag = null;
		maxVelocity = null;
	}
}