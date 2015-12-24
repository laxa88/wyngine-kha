package wyn.component;

class WynCollider extends WynComponent;
{
	public static var HITBOX:Int = 0;
	public static var HITCIRCLE:Int = 1;
	public var colliderType:Int = HITBOX;
	public var width:Int = 0;
	public var height:Int = 0;
	public var radius:Int = 0;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;

	override public function init ()
	{
	}

	override public function update ()
	{
	}

	override public function destroy ()
	{
		super.destroy();
	}



	public function collide (other:WynCollider) : Bool
	{
		// no need to check if there's no size
		if (parent.width == 0 || parent.height == 0 ||
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

	function collideCircleWithCircle (other:WynObject) : Bool
	{
		// Based on code from HaxePunk's Circle.hx
		// https://github.com/HaxePunk/HaxePunk/blob/306f7cc50356a698859434641613b7c95bfbba4f/com/haxepunk/masks/Circle.hx

		// TODO - check if we need to include offsets
		var dx:Float = parent.x - other.parent.x;
		var dy:Float = parent.y - other.parent.y;

		return (dx * dx + dy * dy) < Math.pow(radius + other.radius, 2);
	}
}