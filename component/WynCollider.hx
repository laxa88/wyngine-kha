package wyn.component;

import kha.graphics2.Graphics;
import kha.graphics2.GraphicsExtension;

class WynCollider extends WynComponent
{
	// NOTE
	// collisions do not consider screen's scroll/shake and object's scrollFactor values

	public static var WYN_DEBUG:Bool = false;
	public static var HITBOX:Int = 0;
	public static var HITCIRCLE:Int = 1;
	public var colliderType:Int = HITBOX;
	public var width:Int = 0;
	public var height:Int = 0;
	public var radius:Float = 0;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;



	public function new (w:Int, h:Int)
	{
		super();

		colliderType = HITBOX;

		width = w;
		height = h;
	}

	override public function init ()
	{
		if (WYN_DEBUG)
			parent.addRenderer(debugRender);
	}

	override public function destroy ()
	{
		super.destroy();

		if (WYN_DEBUG)
			parent.removeRenderer(debugRender);
	}



	public function debugRender (g:Graphics)
	{
		// NOTE:
		// color is default white

		// rect is drawn from top-left
		g.drawRect(parent.x + offsetX, parent.y + offsetY, width, height);

		// circle is drawn from top-left, but in logic, x/y position
		// is actually centered, so we need to adjust via (offset + radius)
		GraphicsExtension.drawCircle(g, parent.x+radius+offsetX, parent.y+radius+offsetY, radius);
	}

	public function collide (other:WynCollider) : Bool
	{
		if (!active)
			return false;

		// don't compare with self...
		if (other == this)
			return false;

		// no need to check if there's no size
		if (width == 0 || height == 0 ||
			other.width == 0 || other.height == 0)
		{
			return false;
		}

		if (colliderType == HITBOX)
		{
			if (other.colliderType == HITBOX)
			{
				return collideRectWithRect(other);
			}
			else if (other.colliderType == HITCIRCLE)
			{
				return collideRectWithCircle(other);
			}
		}
		else if (colliderType == HITCIRCLE)
		{
			if (other.colliderType == HITBOX)
			{
				return other.collideRectWithCircle(this);
			}
			else if (other.colliderType == HITCIRCLE)
			{
				return collideCircleWithCircle(other);
			}
		}

		return false;
	}

	function collideRectWithRect (other:WynCollider) : Bool
	{
		// trace ("collideRectWithRect");

		var hitHoriz:Bool = false;
		var hitVert:Bool = false;
		var thisX:Float = parent.x + offsetX;
		var thisY:Float = parent.y + offsetY;
		var otherX:Float = other.parent.x + other.offsetX;
		var otherY:Float = other.parent.y + other.offsetY;

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

	function collideRectWithCircle (other:WynCollider) : Bool
	{
		// trace ("collideRectWithCircle");

		// Based on code from HaxePunk's Circle.hx
		// https://github.com/HaxePunk/HaxePunk/blob/306f7cc50356a698859434641613b7c95bfbba4f/com/haxepunk/masks/Circle.hx

		var _otherHalfWidth:Float = other.width * 0.5;
		var _otherHalfHeight:Float = other.height * 0.5;
		var _squaredRadius:Float = other.radius * other.radius;

		var px:Float = other.parent.x + other.offsetX,
			py:Float = other.parent.y + other.offsetY;

		var ox:Float = parent.x + offsetX,
			oy:Float = parent.y + offsetY;

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

	function collideCircleWithCircle (other:WynCollider) : Bool
	{
		// trace ("collideCircleWithCircle");

		// Based on code from HaxePunk's Circle.hx
		// https://github.com/HaxePunk/HaxePunk/blob/306f7cc50356a698859434641613b7c95bfbba4f/com/haxepunk/masks/Circle.hx

		// TODO - check if we need to include offsets
		var dx:Float = parent.x - other.parent.x;
		var dy:Float = parent.y - other.parent.y;

		return (dx * dx + dy * dy) < Math.pow(radius + other.radius, 2);
	}

	inline public function setOffset (ox:Float, oy:Float)
	{
		offsetX = ox;
		offsetY = oy;
	}

	inline public function setHitCircle (_radius:Float)
	{
		radius = _radius;

		setOffset(-_radius, -_radius);

		colliderType = HITCIRCLE;
	}
}