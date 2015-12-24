package wyn.component;

class WynPhysics extends WynComponent
{
	var oldX:Float = 0;
	var oldY:Float = 0;
	public var velocityX:Float = 0; // current movespeed
	public var velocityY:Float = 0;
	public var accelerationX:Float = 0; // for gravity
	public var accelerationY:Float = 0;
	public var dragX:Float = 0; // for slowing down velocity
	public var dragY:Float = 0;
	public var maxVelocityX:Float = 0;
	public var maxVelocityY:Float = 0;
	public var angularVelocity:Float = 0;
	public var angularAcceleration:Float = 0; // acceleration for angle
	public var angularDrag:Float = 0;
	public var angularMaxVelocity:Float = 0;

	override public function update ()
	{
		if (!active)
			return;

		// Update physics
		velocityX = WynUtil.computeVelocity(Wyngine.dt, velocityX, accelerationX, dragX, maxVelocityX);
		velocityY = WynUtil.computeVelocity(Wyngine.dt, velocityY, accelerationY, dragY, maxVelocityY);
		oldX = parent.x;
		oldY = parent.y;
		parent.x += Wyngine.dt * velocityX;
		parent.y += Wyngine.dt * velocityY;

		// Update rotation
		angularVelocity = WynUtil.computeVelocity(Wyngine.dt, angularVelocity, angularAcceleration, angularDrag, angularMaxVelocity);
		parent.angle += Wyngine.dt * angularVelocity;
	}



	inline public function setVelocity (x:Float, y:Float)
	{
		velocityX = x;
		velocityY = y;
	}

	inline public function setAcceleration (x:Float, y:Float)
	{
		accelerationX = x;
		accelerationY = y;
	}

	inline public function setDrag (x:Float, y:Float)
	{
		dragX = x;
		dragY = y;
	}

	inline public function setMaxVelocity (x:Float, y:Float)
	{
		maxVelocityX = x;
		maxVelocityY = y;
	}
}